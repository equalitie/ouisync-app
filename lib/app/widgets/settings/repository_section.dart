import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../models/repo_entry.dart';
import '../../storage/secure_storage.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'repository_selector.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class RepositorySection extends SettingsSection
    with AppLogger, RepositoryActionsMixin {
  RepositorySection(
    this._cubits, {
    required this.isBiometricsAvailable,
  }) : super(
            title: S.current.titleRepository,
            changed: _cubits.repositories.stream);

  final Cubits _cubits;
  final bool isBiometricsAvailable;

  TextStyle? bodyStyle;

  @override
  List<Widget> buildTiles(BuildContext context) {
    bodyStyle = context.theme.appTextStyle.bodyMedium;

    final currentRepo = _cubits.repositories.currentRepo;

    if (currentRepo is! OpenRepoEntry) {
      return const [];
    }

    return [
      Row(children: [RepositorySelector(_cubits.repositories)]),
      SizedBox(height: 20.0),
      _buildDhtSwitch(context, currentRepo.cubit),
      _buildPeerExchangeSwitch(context, currentRepo.cubit),
      _buildRenameTile(context, currentRepo.cubit),
      _buildShareTile(context, currentRepo.cubit),
      SecurityTile(
        repo: currentRepo.cubit,
        isBiometricsAvailable: isBiometricsAvailable,
      ),
      _buildDeleteTile(context, currentRepo.cubit),
    ];
  }

  Widget _buildDhtSwitch(BuildContext context, RepoCubit repository) =>
      PlatformDhtSwitch(
        repository: repository,
        title: InfoBuble(
            child: Text(S.current.labelBitTorrentDHT, style: bodyStyle),
            title: S.current.labelBitTorrentDHT,
            description: [
              Fields.boldTextSpan(
                  '(${S.current.messageDistributedHashTables})'),
              TextSpan(text: ' ${S.current.messageInfoBittorrentDHT}')
            ]),
        icon: Icons.hub,
        onToggle: (value) => repository.setDhtEnabled(value),
      );

  Widget _buildPeerExchangeSwitch(BuildContext context, RepoCubit repository) =>
      PlatformPexSwitch(
        repository: repository,
        title: InfoBuble(
            child: Text(S.current.messagePeerExchange, style: bodyStyle),
            title: S.current.messagePeerExchange,
            description: [
              TextSpan(text: S.current.messageInfoPeerExchange),
              Fields.linkTextSpan(
                  context,
                  '\n\n${S.current.messagePeerExchangeWikipedia}',
                  _launchPeerExchangeOnWikipedia)
            ]),
        icon: Icons.group_add,
        onToggle: (value) => repository.setPexEnabled(value),
      );

  void _launchPeerExchangeOnWikipedia(BuildContext context) async {
    final title = Text(S.current.messagePeerExchangeWikipedia);
    await Fields.openUrl(context, title, Constants.pexWikipediaUrl);
  }

  Widget _buildRenameTile(
    BuildContext context,
    RepoCubit repository,
  ) =>
      NavigationTile(
          title: Text(S.current.actionRename, style: bodyStyle),
          leading: Icon(Icons.edit),
          onTap: () => renameRepository(context,
              repository: repository,
              rename: _cubits.repositories.renameRepository));

  Widget _buildShareTile(BuildContext context, RepoCubit repository) =>
      NavigationTile(
        title: Text(S.current.actionShare, style: bodyStyle),
        leading: Icon(Icons.share),
        onTap: () => shareRepository(context, repository: repository),
      );

  Widget _buildDeleteTile(BuildContext context, RepoCubit repository) =>
      NavigationTile(
          title: Text(S.current.actionDelete,
              style: bodyStyle?.copyWith(color: Constants.dangerColor)),
          leading: Icon(Icons.delete, color: Constants.dangerColor),
          onTap: () async {
            final repoName = repository.name;
            final metaInfo = repository.metaInfo;
            final getAuthenticationModeCallback =
                _cubits.repositories.settings.getAuthenticationMode;
            final deleteRepositoryCallback =
                _cubits.repositories.deleteRepository;

            await deleteRepository(
              context,
              repositoryName: repoName,
              repositoryMetaInfo: metaInfo,
              getAuthenticationMode: getAuthenticationModeCallback,
              delete: deleteRepositoryCallback,
            );
          });
}

class SecurityTile extends StatefulWidget {
  final RepoCubit repo;
  final bool isBiometricsAvailable;

  SecurityTile({required this.repo, required this.isBiometricsAvailable});

  @override
  State<SecurityTile> createState() => _SecurityTileState();
}

class _SecurityTileState extends State<SecurityTile>
    with AppLogger, RepositoryActionsMixin {
  SecurityCubit? _security;

  TextStyle? bodyStyle;

  @override
  void initState() {
    super.initState();

    _security = SecurityCubit.create(
      repoCubit: widget.repo,
      shareToken: null,
      isBiometricsAvailable: widget.isBiometricsAvailable,
      authenticationMode: widget.repo.state.authenticationMode,
      password: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    bodyStyle = context.theme.appTextStyle.bodyMedium;

    return BlocBuilder<SecurityCubit, SecurityState>(
        bloc: _security,
        builder: (context, state) => Column(children: [
              _addLocalPassword(context, state, widget.repo),
              _password(context, state, widget.repo),
              _biometrics(context, state, widget.repo)
            ]));
  }

  Widget _addLocalPassword(
    BuildContext context,
    SecurityState state,
    RepoCubit repository,
  ) =>
      state.passwordMode == PasswordMode.none
          ? NavigationTile(
              title: Text(S.current.messageAddLocalPassword, style: bodyStyle),
              leading: Icon(Icons.password),
              onTap: () async {
                final setPasswordResult = await _getNewLocalPassword(context,
                    repository: repository,
                    action: PasswordAction.add,
                    repoName: repository.name,
                    authMode: state.authMode,
                    useBiometrics: state.unlockWithBiometrics);

                if (setPasswordResult == null) {
                  return;
                }

                final newPassword = setPasswordResult.newPassword;

                final result = setPasswordResult.unlockResult;
                if (result == null) {
                  return;
                }

                final currentPassword = result.password;
                final shareToken = result.shareToken;

                _security?.setPassword(currentPassword);
                _security?.setShareToken(shareToken);

                final addLocalPasswordResult =
                    await _security?.addRepoLocalPassword(newPassword);

                if (addLocalPasswordResult != null) {
                  showSnackBar(context, message: addLocalPasswordResult);
                }
              })
          : const SizedBox.shrink();

  Future<SetPasswordResult?> _getNewLocalPassword(
    BuildContext context, {
    required RepoCubit repository,
    required PasswordAction action,
    required String repoName,
    required AuthMode authMode,
    required bool useBiometrics,
  }) async {
    final title = action == PasswordAction.add
        ? S.current.messageAddLocalPassword
        : action == PasswordAction.change
            ? S.current.messageChangeLocalPassword
            : action == PasswordAction.remove
                ? S.current.messageRemovaLocalPassword
                : S.current.messageValidateLocalPassword;

    final newPasswordState = await showDialog<SetPasswordResult>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: title,
            body: ManageDesktopPassword(
                context: context,
                repoCubit: repository,
                action: action,
                repositoryName: repoName,
                authMode: authMode,
                usesBiometrics: useBiometrics)));

    if (newPasswordState == null) {
      return null;
    }

    return newPasswordState;
  }

  Widget _password(
    BuildContext context,
    SecurityState state,
    RepoCubit repository,
  ) =>
      state.passwordMode == PasswordMode.manual
          ? Column(children: [
              NavigationTile(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 0,
                            child: Text(S.current.messageChangeLocalPassword,
                                style: bodyStyle))
                      ]),
                  leading: Icon(Icons.change_circle_outlined),
                  onTap: () async {
                    final setPasswordResult = await _getNewLocalPassword(
                        context,
                        repository: repository,
                        action: PasswordAction.change,
                        repoName: repository.name,
                        authMode: state.authMode,
                        useBiometrics: state.unlockWithBiometrics);

                    if (setPasswordResult == null) {
                      return;
                    }

                    final newPassword = setPasswordResult.newPassword;

                    final result = setPasswordResult.unlockResult;
                    if (result == null) {
                      return;
                    }

                    final currentPassword = result.password;
                    final shareToken = result.shareToken;

                    _security?.setPassword(currentPassword);
                    _security?.setShareToken(shareToken);

                    final updateRepoLocalPasswordResult =
                        await _security?.updateRepoLocalPassword(newPassword);

                    if (updateRepoLocalPasswordResult != null) {
                      showSnackBar(context,
                          message: updateRepoLocalPasswordResult);
                      return;
                    }
                  }),
              NavigationTile(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 0,
                            child: Text(S.current.messageRemovaLocalPassword,
                                style: bodyStyle))
                      ]),
                  leading: Icon(Icons.remove),
                  onTap: () async {
                    final setPasswordResult = await _getNewLocalPassword(
                        context,
                        repository: repository,
                        action: PasswordAction.remove,
                        repoName: repository.name,
                        authMode: state.authMode,
                        useBiometrics: state.unlockWithBiometrics);

                    if (setPasswordResult == null) {
                      return;
                    }

                    final result = setPasswordResult.unlockResult;
                    if (result == null) {
                      return;
                    }

                    final currentPassword = result.password;
                    final shareToken = result.shareToken;

                    _security?.setPassword(currentPassword);
                    _security?.setShareToken(shareToken);

                    final removeRepoLocalPasswordResult =
                        await _security?.removeRepoLocalPassword();

                    if (removeRepoLocalPasswordResult != null) {
                      showSnackBar(context,
                          message: removeRepoLocalPasswordResult);
                    }
                  }),
            ])
          : const SizedBox.shrink();

  Widget _biometrics(
    BuildContext context,
    SecurityState state,
    RepoCubit repository,
  ) =>
      state.isBiometricsAvailable
          ? SwitchListTile.adaptive(
              value: state.unlockWithBiometrics,
              onChanged: (useBiometrics) async {
                UnlockResult? unlockResult;

                if (state.authMode != AuthMode.manual) {
                  /// If we are switching from a no local password situation
                  /// to a biometric validation, we first do a biometric check
                  if (useBiometrics) {
                    final auth = LocalAuthentication();

                    final authorized = await auth.authenticate(
                        localizedReason:
                            S.current.messageAccessingSecureStorage);

                    if (authorized == false) {
                      return;
                    }
                  }

                  final securePassword =
                      await SecureStorage(databaseId: repository.databaseId)
                          .tryGetPassword(authMode: state.authMode);

                  if (securePassword == null || securePassword.isEmpty) {
                    if (securePassword != null) {
                      final userAuthenticationFailed =
                          state.authMode == AuthMode.noLocalPassword
                              ? S.current.messageRepoAuthFailed
                              : S.current.messageBioAuthFailed;
                      showSnackBar(context, message: userAuthenticationFailed);
                    }

                    return;
                  }

                  final validateCurrentPassword =
                      await _validateCurrentPassword(
                          context, securePassword, repository);

                  if (validateCurrentPassword.isFailure) {
                    final message = validateCurrentPassword.failure;

                    if (message != null) {
                      showSnackBar(context, message: message);
                    }

                    return;
                  }

                  unlockResult = validateCurrentPassword.success;
                } else {
                  final setPasswordResult = await _getNewLocalPassword(context,
                      repository: repository,
                      action: PasswordAction.biometrics,
                      repoName: repository.name,
                      authMode: state.authMode,
                      useBiometrics: state.unlockWithBiometrics);

                  if (setPasswordResult == null) {
                    return;
                  }

                  unlockResult = setPasswordResult.unlockResult;
                }

                if (unlockResult == null) {
                  return;
                }

                final currentPassword = unlockResult.password;
                final shareToken = unlockResult.shareToken;

                _security?.setPassword(currentPassword);
                _security?.setShareToken(shareToken);

                final updateUnlockRepoWithBiometricsResult = await _security
                    ?.updateUnlockRepoWithBiometrics(useBiometrics);

                if (updateUnlockRepoWithBiometricsResult != null) {
                  showSnackBar(context,
                      message: updateUnlockRepoWithBiometricsResult);
                  return;
                }
              },
              title: Text(S.current.messageUnlockUsingBiometrics,
                  style: bodyStyle),
              secondary: Icon(Icons.fingerprint_outlined))
          : const SizedBox.shrink();

  Future<Result<UnlockResult, String?>> _validateCurrentPassword(
    BuildContext parentContext,
    String currentPassword,
    RepoCubit repoCubit,
  ) async {
    final unlockResult =
        await getShareTokenAtUnlock(repoCubit, password: currentPassword);

    final accessMode = await unlockResult.shareToken.mode;
    if (accessMode == AccessMode.blind) {
      return Failure(S.current.messageUnlockRepoFailed);
    }

    return Success(unlockResult);
  }
}
