import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../../../mixins/mixins.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../../widgets.dart';
import '../repository_selector.dart';

class RepositoryDesktopDetail extends StatefulWidget {
  const RepositoryDesktopDetail(this.context,
      {required this.item,
      required this.reposCubit,
      required this.isBiometricsAvailable});

  final BuildContext context;
  final SettingItem item;
  final ReposCubit reposCubit;
  final bool isBiometricsAvailable;

  @override
  State<RepositoryDesktopDetail> createState() =>
      _RepositoryDesktopDetailState();
}

class _RepositoryDesktopDetailState extends State<RepositoryDesktopDetail>
    with RepositoryActionsMixin {
  SecurityCubit? _security;

  @override
  Widget build(BuildContext context) => widget.reposCubit.builder((repos) {
        final currentRepo = repos.currentRepo;

        if (currentRepo is! OpenRepoEntry) {
          return const SizedBox.shrink();
        }

        _security = SecurityCubit.create(
            repoCubit: currentRepo.cubit,
            shareToken: null,
            isBiometricsAvailable: widget.isBiometricsAvailable,
            authenticationMode: currentRepo.cubit.state.authenticationMode,
            password: '');

        return Column(children: [
          Row(children: [RepositorySelector(widget.reposCubit)]),
          SizedBox(height: 20.0),
          _buildTile(context, currentRepo, _buildDhtSwitch),
          _buildTile(context, currentRepo, _buildPeerExchangeSwitch),
          _buildTile(context, currentRepo, _buildRenameTile),
          _buildTile(context, currentRepo, _buildShareTile),
          _buildTile(context, currentRepo, _buildSecurityTile),
          _buildTile(context, currentRepo, _buildDeleteTile),
        ]);
      });

  Widget _buildTile(BuildContext context, RepoEntry currentRepo,
      Widget Function(BuildContext, RepoCubit) builder) {
    final tile = currentRepo is OpenRepoEntry
        ? BlocBuilder<RepoCubit, RepoState>(
            bloc: currentRepo.cubit,
            builder: (context, state) => builder(context, currentRepo.cubit))
        : SizedBox.shrink();

    return tile;
  }

  Widget _buildDhtSwitch(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        PlatformDhtSwitch(
            repository: repository,
            title: S.current.labelBitTorrentDHT,
            icon: Icons.hub,
            onToggle: (value) => repository.setDhtEnabled(value)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildPeerExchangeSwitch(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        PlatformPexSwitch(
            repository: repository,
            title: S.current.messagePeerExchange,
            icon: Icons.group_add,
            onToggle: (value) => repository.setPexEnabled(value)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildRenameTile(BuildContext context, RepoCubit repository) =>
      PlatformTappableTile(
          title: Text(S.current.actionRename),
          icon: Icons.edit,
          onTap: (_) async => await renameRepository(widget.context,
              repository: repository,
              rename: widget.reposCubit.renameRepository));

  Widget _buildShareTile(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        PlatformTappableTile(
            title: Text(S.current.actionShare),
            icon: Icons.share,
            onTap: (_) async =>
                await shareRepository(context, repository: repository)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildSecurityTile(BuildContext context, RepoCubit repository) =>
      BlocBuilder<SecurityCubit, SecurityState>(
          bloc: _security,
          builder: (context, state) => Column(children: [
                _addLocalPassword(state, repository),
                _password(state, repository),
                _biometrics(state, repository)
              ]));

  Widget _buildDeleteTile(BuildContext context, RepoCubit repository) =>
      Column(children: [
        Row(children: [
          Text(S.current.actionDelete, textAlign: TextAlign.start)
        ]),
        ListTile(
            leading: const Icon(Icons.delete, color: Constants.dangerColor),
            title: Row(children: [
              TextButton(
                  onPressed: () async {
                    final repoName = repository.name;
                    final metaInfo = repository.metaInfo;
                    final getAuthenticationModeCallback =
                        widget.reposCubit.settings.getAuthenticationMode;
                    final deleteRepositoryCallback =
                        widget.reposCubit.deleteRepository;

                    await deleteRepository(widget.context,
                        repositoryName: repoName,
                        repositoryMetaInfo: metaInfo,
                        getAuthenticationMode: getAuthenticationModeCallback,
                        delete: deleteRepositoryCallback);
                  },
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      child: Text(S.current.actionDeleteRepository)),
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white))
            ]))
      ]);

  /// *************************************************
  ///                                                 *
  /// REPOSITORY SECURITY METHODS                     *
  ///                                                 *
  /// *************************************************

  Widget _addLocalPassword(SecurityState state, RepoCubit repository) =>
      state.passwordMode == PasswordMode.none
          ? Column(children: [
              PlatformTappableTile(
                  title: Text(S.current.messageAddLocalPassword),
                  icon: Icons.password,
                  onTap: (_) async {
                    final setPasswordResult = await _getNewLocalPassword(
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
                  }),
              if (widget.isBiometricsAvailable == false)
                Dimensions.desktopSettingDivider
            ])
          : const SizedBox.shrink();

  Future<SetPasswordResult?> _getNewLocalPassword(
      {required RepoCubit repository,
      required PasswordAction action,
      required String repoName,
      required AuthMode authMode,
      required bool useBiometrics}) async {
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

  Widget _password(SecurityState state, RepoCubit repository) => state
              .passwordMode ==
          PasswordMode.manual
      ? Column(children: [
          PlatformTappableTile(
              title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    flex: 0, child: Text(S.current.messageChangeLocalPassword))
              ]),
              icon: Icons.change_circle_outlined,
              onTap: (_) async {
                final setPasswordResult = await _getNewLocalPassword(
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
                  showSnackBar(context, message: updateRepoLocalPasswordResult);
                  return;
                }
              }),
          PlatformTappableTile(
              title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    flex: 0, child: Text(S.current.messageRemovaLocalPassword))
              ]),
              icon: Icons.remove,
              onTap: (_) async {
                final setPasswordResult = await _getNewLocalPassword(
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
                  showSnackBar(context, message: removeRepoLocalPasswordResult);
                }
              }),
          if (state.isBiometricsAvailable == false)
            Dimensions.desktopSettingDivider
        ])
      : const SizedBox.shrink();

  Widget _biometrics(SecurityState state, RepoCubit repository) => state
          .isBiometricsAvailable
      ? Column(children: [
          SwitchListTile.adaptive(
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

                  final securePassword = await tryGetSecurePassword(
                      context: context,
                      databaseId: repository.databaseId,
                      authenticationMode: state.authMode);

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
                  final setPasswordResult = await _getNewLocalPassword(
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
              title: Text(S.current.messageUnlockUsingBiometrics),
              secondary: Icon(Icons.fingerprint_outlined)),
          Dimensions.desktopSettingDivider
        ])
      : const SizedBox.shrink();

  Future<Result<UnlockResult, String?>> _validateCurrentPassword(
      BuildContext parentContext,
      String currentPassword,
      RepoCubit repoCubit) async {
    final unlockResult =
        await getShareTokenAtUnlock(repoCubit, password: currentPassword);

    final accessMode = await unlockResult.shareToken.mode;
    if (accessMode == AccessMode.blind) {
      return Failure(S.current.messageUnlockRepoFailed);
    }

    return Success(unlockResult);
  }
}
