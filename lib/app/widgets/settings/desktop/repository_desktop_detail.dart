import 'package:badges/badges.dart' as b;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../../../cubits/security.dart';
import '../../../mixins/mixins.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../../widgets.dart';
import '../repository_selector.dart';

class RepositoryDesktopDetail extends StatefulWidget {
  const RepositoryDesktopDetail(
      {required this.item,
      required this.reposCubit,
      required this.isBiometricsAvailable,
      required this.onGetPasswordFromUser,
      required this.onRenameRepository,
      required this.onDeleteRepository});

  final SettingItem item;
  final ReposCubit reposCubit;
  final bool isBiometricsAvailable;

  final Future<UnlockResult?> Function(
      BuildContext parentContext, RepoCubit repo) onGetPasswordFromUser;
  final Future<void> Function(dynamic context) onRenameRepository;
  final Future<void> Function(dynamic context) onDeleteRepository;

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

  Widget _buildRenameTile(BuildContext context, _) => PlatformTappableTile(
      title: Text(S.current.actionRename),
      icon: Icons.edit,
      onTap: (_) async => await widget.onRenameRepository(context));

  Widget _buildShareTile(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        PlatformTappableTile(
            title: Text(S.current.actionShare),
            icon: Icons.share,
            onTap: (_) async =>
                shareRepository(context, repository: repository)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildSecurityTile(BuildContext context, RepoCubit repository) =>
      BlocBuilder<SecurityCubit, SecurityState>(
          bloc: _security,
          builder: (context, state) => Column(children: [
                _addLocalPassword(state, repository),
                _password(state, repository),
                _biometrics(state, repository),
                _saveChanges(state, repository)
              ]));

  Widget _buildDeleteTile(BuildContext context, _) => Column(children: [
        Row(children: [
          Text(S.current.actionDelete, textAlign: TextAlign.start)
        ]),
        ListTile(
            leading: const Icon(Icons.delete, color: Constants.dangerColor),
            title: Row(children: [
              TextButton(
                  onPressed: () async =>
                      await widget.onDeleteRepository(context),
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
      state.showAddPassword
          ? Opacity(
              opacity: state.useBiometrics ? 0.3 : 1,
              child: Column(children: [
                PlatformTappableTile(
                    title: Text(S.current.messageAddLocalPassword),
                    icon: Icons.password,
                    onTap: state.useBiometrics
                        ? null
                        : (_) async {
                            final setPasswordResult =
                                await _getNewLocalPassword(
                                    repository: repository,
                                    mode: Constants.addPasswordMode,
                                    repoName: repository.name,
                                    authMode: state.currentAuthMode,
                                    currentPassword: state.currentPassword,
                                    newPassword: state.newPassword,
                                    useBiometrics: state.useBiometrics);

                            if (setPasswordResult == null) {
                              return;
                            }

                            final newPassword = setPasswordResult.newPassword;
                            _security?.setNewPassword(newPassword);

                            final result = setPasswordResult.unlockResult;
                            if (result == null) {
                              return;
                            }

                            final currentPassword = result.password;
                            final shareToken = result.shareToken;

                            _security?.setCurrentPassword(currentPassword);
                            _security?.setShareToken(shareToken);
                          }),
                if (widget.isBiometricsAvailable == false)
                  Dimensions.desktopSettingDivider
              ]))
          : const SizedBox.shrink();

  Future<SetPasswordResult?> _getNewLocalPassword(
      {required RepoCubit repository,
      required String mode,
      required String repoName,
      required String authMode,
      required String currentPassword,
      required String newPassword,
      required bool useBiometrics}) async {
    final title = mode == Constants.addPasswordMode
        ? S.current.messageAddLocalPassword
        : mode == Constants.changePasswordMode
            ? S.current.messageChangeLocalPassword
            : S.current.messageRemovaLocalPassword;

    final newPasswordState = await showDialog<SetPasswordResult>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: title,
            body: ManageDesktopPassword(
                context: context,
                repoCubit: repository,
                mode: mode,
                repositoryName: repoName,
                authMode: authMode,
                currentPassword: currentPassword,
                newPassword: newPassword,
                usesBiometrics: useBiometrics,
                onGetPasswordFromUser: widget.onGetPasswordFromUser)));

    if (newPasswordState == null) {
      return null;
    }

    return newPasswordState;
  }

  Widget _password(SecurityState state, RepoCubit repository) => state
          .showManagePassword
      ? Column(children: [
          Opacity(
              opacity: state.removePassword || state.useBiometrics ? 0.3 : 1,
              child: PlatformTappableTile(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 0,
                            child: _buildBadge(
                                Text(S.current.messageChangeLocalPassword),
                                state.isUnsavedNewPassword)),
                        Visibility(
                            visible: state.isUnsavedNewPassword,
                            child: Expanded(
                                flex: 1,
                                child: Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 16.0),
                                    child: TextButton(
                                        child: Text(S.current.actionUndo),
                                        onPressed: state.removePassword ||
                                                state.useBiometrics
                                            ? null
                                            : () {
                                                _security?.clearNewPassword();
                                                _security?.setNewAuthMode('');
                                              }))))
                      ]),
                  icon: Icons.change_circle_outlined,
                  onTap: state.removePassword || state.useBiometrics
                      ? null
                      : (_) async {
                          final passwordMode = state.currentAuthMode ==
                                  Constants.authModeNoLocalPassword
                              ? Constants.addPasswordMode
                              : Constants.changePasswordMode;

                          final setPasswordResult = await _getNewLocalPassword(
                              repository: repository,
                              mode: passwordMode,
                              repoName: repository.name,
                              authMode: state.currentAuthMode,
                              currentPassword: state.currentPassword,
                              newPassword: state.newPassword,
                              useBiometrics: state.useBiometrics);

                          if (setPasswordResult == null) {
                            return;
                          }

                          final newPassword = setPasswordResult.newPassword;
                          _security?.setNewPassword(newPassword);

                          final result = setPasswordResult.unlockResult;
                          if (result == null) {
                            return;
                          }

                          final currentPassword = result.password;
                          final shareToken = result.shareToken;

                          _security?.setCurrentPassword(currentPassword);
                          _security?.setShareToken(shareToken);
                        })),
          Opacity(
              opacity: state.useBiometrics ? 0.3 : 1,
              child: PlatformTappableTile(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 0,
                            child: _buildBadge(
                                Text(S.current.messageRemovaLocalPassword),
                                state.removePassword)),
                        Visibility(
                            visible: state.removePassword,
                            child: Expanded(
                                flex: 1,
                                child: Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 16.0),
                                    child: TextButton(
                                        child: Text(S.current.actionUndo),
                                        onPressed: state.useBiometrics
                                            ? null
                                            : () {
                                                final value =
                                                    !state.removePassword;

                                                _security
                                                    ?.setRemovePassword(value);

                                                if (value == true) {
                                                  _security?.clearNewPassword();
                                                }
                                              }))))
                      ]),
                  icon: Icons.remove,
                  onTap: state.useBiometrics
                      ? null
                      : (_) async {
                          final setPasswordResult = await _getNewLocalPassword(
                              repository: repository,
                              mode: Constants.removePasswordMode,
                              repoName: repository.name,
                              authMode: state.currentAuthMode,
                              currentPassword: state.currentPassword,
                              newPassword: '',
                              useBiometrics: state.useBiometrics);

                          if (setPasswordResult == null) {
                            return;
                          }

                          _security?.setRemovePassword(true);

                          final result = setPasswordResult.unlockResult;
                          if (result == null) {
                            return;
                          }

                          final currentPassword = result.password;
                          final shareToken = result.shareToken;

                          _security?.setCurrentPassword(currentPassword);
                          _security?.setShareToken(shareToken);
                        })),
          if (state.isBiometricsAvailable == false)
            Dimensions.desktopSettingDivider
        ])
      : const SizedBox.shrink();

  Widget _buildBadge(Widget child, bool showBadge) => b.Badge(
      showBadge: showBadge,
      padding: EdgeInsets.all(2.0),
      alignment: Alignment.centerLeft,
      position: b.BadgePosition.topEnd(),
      child: child);

  Widget _biometrics(SecurityState state, RepoCubit repository) =>
      state.isBiometricsAvailable
          ? Column(children: [
              SwitchListTile.adaptive(
                  value: state.useBiometrics,
                  onChanged: (useBiometrics) {
                    String authMode = useBiometrics
                        ? Constants.authModeVersion2
                        : state.newPassword.isNotEmpty
                            ? Constants.authModeManual
                            : state.currentAuthMode;

                    _security?.setNewAuthMode(authMode);
                    _security?.setUnlockWithBiometrics(useBiometrics);
                  },
                  title: Text(S.current.messageUnlockUsingBiometrics),
                  secondary: Icon(Icons.fingerprint_outlined)),
              if (state.hasUnsavedChanges == false)
                Dimensions.desktopSettingDivider
            ])
          : const SizedBox.shrink();

  Widget _saveChanges(SecurityState state, RepoCubit repository) => state
          .hasUnsavedChanges
      ? Column(children: [
          Dimensions.spacingVerticalDouble,
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
                onPressed: () async {
                  final saveChanges = await _confirmSaveChanges(context, state);

                  if (saveChanges == null || !saveChanges) return;

                  if (state.currentAuthMode ==
                      Constants.authModeNoLocalPassword) {
                    await Dialogs.executeFutureWithLoadingDialog(context,
                        f: _saveNoLocalPasswordChanges(state));
                    return;
                  }

                  if (state.currentAuthMode == Constants.authModeManual) {
                    await Dialogs.executeFutureWithLoadingDialog(context,
                        f: _saveManualPasswordChanges(state));
                    return;
                  }

                  await Dialogs.executeFutureWithLoadingDialog(context,
                      f: _saveBiometricChanges(state));
                },
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    child: Text(S.current.actionSaveChanges)),
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white))
          ]),
          Dimensions.desktopSettingDivider
        ])
      : const SizedBox.shrink();

  Future<void> _saveNoLocalPasswordChanges(SecurityState state) async {
    String? authMode = state.useBiometrics
        ? Constants.authModeVersion2
        : Constants.authModeManual;

    if (state.newPassword.isNotEmpty) {
      final changed =
          await _security?.changeRepositoryPassword(state.newPassword);

      if (changed == false) {
        final errorMessage = S.current.messageErrorAddingLocalPassword;
        showSnackBar(context, message: errorMessage);

        return;
      }

      _security?.setCurrentPassword(state.newPassword);
    }

    if (state.useBiometrics) {
      _security?.setCurrentUnlockWithBiometrics(true);
    }

    _security?.setNewAuthMode('');
    _security?.clearNewPassword();

    _security?.setCurrentAuthMode(authMode);
  }

  Future<void> _saveManualPasswordChanges(SecurityState state) async {
    String authMode = state.useBiometrics
        ? Constants.authModeVersion2
        : Constants.authModeManual;

    if (state.removePassword) {
      authMode = state.useBiometrics
          ? Constants.authModeVersion2
          : Constants.authModeNoLocalPassword;
    }

    final password = state.removePassword
        ? generateRandomPassword()
        : state.newPassword.isNotEmpty
            ? state.newPassword
            : state.currentPassword;

    if (password != state.currentPassword) {
      final changed = await _security?.changeRepositoryPassword(password);

      if (changed == false) {
        final errorMessage = S.current.messageErrorChangingLocalPassword;
        showSnackBar(context, message: errorMessage);

        return;
      }
    }

    if (state.removePassword || state.useBiometrics) {
      final addedToSecureStorage =
          await _security?.addPasswordToSecureStorage(password, authMode);

      if (addedToSecureStorage == false) {
        showSnackBar(context, message: S.current.messageErrorRemovingPassword);

        return;
      }

      if (state.useBiometrics) {
        _security?.setCurrentUnlockWithBiometrics(true);
      }

      if (state.removePassword) {
        _security?.setRemovePassword(false);
      }
    }

    if (password != state.currentPassword) {
      _security?.setCurrentPassword(password);
    }

    if (authMode != state.currentAuthMode) {
      _security?.setCurrentAuthMode(authMode);
    }

    _security?.setNewAuthMode('');
    _security?.clearNewPassword();
  }

  Future<void> _saveBiometricChanges(SecurityState state) async {
    final authMode = state.useBiometrics
        ? Constants.authModeVersion2
        : state.newPassword.isEmpty
            ? Constants.authModeNoLocalPassword
            : Constants.authModeManual;

    if (state.newPassword.isNotEmpty) {
      final changed =
          await _security?.changeRepositoryPassword(state.newPassword);

      if (changed == false) {
        final errorMessage = S.current.messageErrorAddingSecureStorge;
        showSnackBar(context, message: errorMessage);

        return;
      }

      _security?.setCurrentPassword(state.newPassword);

      if (state.useBiometrics) {
        final updated = await _security?.updatePasswordInSecureStorage(
            state.newPassword, authMode);

        if (updated == false) {
          showSnackBar(context,
              message: S.current.messageErrorUpdatingSecureStorage);

          _security?.setCurrentUnlockWithBiometrics(false);
          _security?.setCurrentPassword(state.newPassword);
          _security?.setCurrentAuthMode(Constants.authModeManual);

          _security?.clearNewPassword();
          _security?.setNewAuthMode('');

          return;
        }
      }
    }

    if (state.useBiometrics == false) {
      if (state.newPassword.isNotEmpty) {
        final deleted = await _security
            ?.removePasswordFromSecureStorage(state.currentAuthMode);

        if (deleted == false) {
          showSnackBar(context,
              message: S.current.messageErrorRemovingSecureStorage);

          _security?.setCurrentUnlockWithBiometrics(false);
          _security?.setCurrentPassword(state.newPassword);
          _security?.setCurrentAuthMode(Constants.authModeManual);

          _security?.clearNewPassword();
          _security?.setNewAuthMode('');

          return;
        }
      }

      _security?.setCurrentUnlockWithBiometrics(false);
    }

    _security?.setCurrentAuthMode(authMode);

    _security?.clearNewPassword();
    _security?.setNewAuthMode('');
  }

  Future<bool?> _confirmSaveChanges(
      BuildContext context, SecurityState currentState) async {
    final saveChanges = await Dialogs.alertDialogWithActions(
        context: context,
        title: S.current.titleSaveChanges,
        body: [
          Text(S.current.messageSavingChanges)
        ],
        actions: [
          TextButton(
              child: Text(S.current.actionSave),
              onPressed: () => Navigator.of(context).pop(true)),
          TextButton(
              child: Text(S.current.actionCancel),
              onPressed: () => Navigator.of(context).pop(false))
        ]);

    return saveChanges;
  }
}
