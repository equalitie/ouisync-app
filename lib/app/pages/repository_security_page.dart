import 'dart:async';

import 'package:badges/badges.dart' as b;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../cubits/security.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class RepositorySecurity extends StatefulWidget {
  const RepositorySecurity(
      {required this.repo,
      required this.password,
      required this.shareToken,
      required this.isBiometricsAvailable,
      required this.authenticationMode});

  final RepoCubit repo;
  final String password;
  final ShareToken shareToken;
  final bool isBiometricsAvailable;
  final String authenticationMode;

  @override
  State<RepositorySecurity> createState() => _RepositorySecurityState();
}

class _RepositorySecurityState extends State<RepositorySecurity>
    with OuiSyncAppLogger {
  late final SecurityCubit security;

  @override
  void initState() {
    security = SecurityCubit.create(
        repoCubit: widget.repo,
        shareToken: widget.shareToken,
        isBiometricsAvailable: widget.isBiometricsAvailable,
        authenticationMode: widget.authenticationMode,
        password: widget.password);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(S.current.titleSecurity), elevation: 0.0),
      body: WillPopScope(
          child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(children: [
                    _addLocalPassword(
                        context, security.state.isBiometricsAvailable),
                    _password(),
                    _biometrics(),
                    _saveChanges()
                  ]))),
          onWillPop: () async => await _onBackPressed(context)));

  Future<bool> _onBackPressed(BuildContext context) async {
    if (security.state.hasUnsavedChanges) {
      final discardChanges = await _discardUnsavedChangesAlert(context);
      return discardChanges ?? false;
    }

    return true;
  }

  Future<bool?> _discardUnsavedChangesAlert(BuildContext context) async =>
      await Dialogs.alertDialogWithActions(
          context: context,
          title: S.current.titleUnsavedChanges,
          body: [
            Text(S.current.messageUnsavedChanges)
          ],
          actions: [
            TextButton(
                child: Text(S.current.actionDiscard),
                onPressed: () => Navigator.of(context).pop(true)),
            TextButton(
                child: Text(S.current.actionCancel),
                onPressed: () => Navigator.of(context).pop(false))
          ]);

  Widget _addLocalPassword(BuildContext context, bool isBiometricsAvailable) =>
      BlocBuilder<SecurityCubit, SecurityState>(
          bloc: security,
          builder: (context, state) => state.showAddPassword
              ? Opacity(
                  opacity: state.useBiometrics ? 0.3 : 1,
                  child: Column(children: [
                    ListTile(
                        leading: const Icon(Icons.password_rounded,
                            color: Colors.black),
                        title: Text(S.current.messageAddLocalPassword),
                        onTap: state.useBiometrics
                            ? null
                            : () async {
                                final passwordState = GetPasswordResult(
                                    mode: Constants.addPasswordMode,
                                    currentPassword: '');

                                final newPasswordState =
                                    await Navigator.push<GetPasswordResult>(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GetPasswordState(
                                                    passwordState:
                                                        passwordState)));

                                if (newPasswordState == null) {
                                  return;
                                }

                                if (newPasswordState.changed) {
                                  final newPassword =
                                      newPasswordState.newPassword == null
                                          ? ''
                                          : newPasswordState.newPassword!;

                                  security.setNewPassword(newPassword);
                                  security
                                      .setNewAuthMode(Constants.authModeManual);
                                }
                              }),
                    Divider()
                  ]))
              : SizedBox());

  Widget _password() => BlocBuilder<SecurityCubit, SecurityState>(
      bloc: security,
      builder: (context, state) {
        final password = state.newPassword.isEmpty
            ? state.currentPassword
            : state.newPassword;

        final actionsEnabled = password.isNotEmpty;

        final canRemove = (state.currentAuthMode == Constants.authModeManual &&
            state.newPassword.isEmpty);

        return state.showManagePassword
            ? Column(children: [
                ListTile(
                    leading:
                        const Icon(Icons.password_rounded, color: Colors.black),
                    title: b.Badge(
                        showBadge:
                            state.isUnsavedNewPassword || state.removePassword,
                        padding: EdgeInsets.all(2.0),
                        alignment: Alignment.centerLeft,
                        position: b.BadgePosition.topEnd(),
                        child: Text(
                            state.currentAuthMode != Constants.authModeManual
                                ? S.current.messageNewPassword
                                : S.current.messagePassword)),
                    subtitle: Fields.autosizeText(state.removePassword
                        ? S.current.messageRemovedInBrackets
                        : maskPassword(password, mask: !state.previewPassword)),
                    trailing: state.removePassword
                        ? SizedBox()
                        : _passwordActions(context, password,
                            state.previewPassword, actionsEnabled),
                    onTap: () async {
                      if (state.removePassword) {
                        return;
                      }

                      final passwordMode = state.currentAuthMode ==
                              Constants.authModeNoLocalPassword
                          ? Constants.addPasswordMode
                          : Constants.changePasswordMode;

                      final getPasswordResult = await _getNewPassword(
                          passwordMode,
                          state.currentPassword,
                          state.newPassword);

                      if (getPasswordResult == null) {
                        return;
                      }

                      if (getPasswordResult.changed) {
                        final newPassword = getPasswordResult.newPassword ?? '';

                        security.setNewPassword(newPassword);

                        if (passwordMode == Constants.addPasswordMode) {
                          security.setNewAuthMode(Constants.authModeManual);
                        }
                      }
                    }),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                      padding: EdgeInsets.only(right: 16.0),
                      child: TextButton(
                          child: Text(state.removePassword
                              ? S.current.actionUndo
                              : S.current.actionRemove),
                          onPressed: canRemove
                              ? () {
                                  final value = !state.removePassword;

                                  security.setRemovePassword(value);

                                  if (value == true) {
                                    security.clearNewPassword();
                                  }
                                }
                              : null)),
                  Visibility(
                      visible:
                          state.currentAuthMode == Constants.authModeVersion2
                              ? true
                              : state.isUnsavedNewPassword,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                padding: EdgeInsets.only(right: 16.0),
                                child: TextButton(
                                    child: Text(S.current.actionUndo),
                                    onPressed: (() {
                                      security.clearNewPassword();
                                      security.setNewAuthMode('');
                                    })))
                          ]))
                ]),
                Divider()
              ])
            : SizedBox();
      });

  Widget _passwordActions(BuildContext context, String password,
          bool previewPassword, bool enabled) =>
      Wrap(children: [
        IconButton(
            icon: previewPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor,
            onPressed: enabled ? security.switchPreviewPassword : null),
        IconButton(
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor,
            onPressed: enabled
                ? () async {
                    await copyStringToClipboard(password);
                    showSnackBar(context,
                        message: S.current.messagePasswordCopiedClipboard);
                  }
                : null)
      ]);

  Future<GetPasswordResult?> _getNewPassword(
      String mode, String currentPassword, String newPassword) async {
    final passwordState = GetPasswordResult(
        mode: mode, currentPassword: currentPassword, newPassword: newPassword);

    return await Navigator.push<GetPasswordResult>(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GetPasswordState(passwordState: passwordState)));
  }

  Widget _biometrics() => BlocBuilder<SecurityCubit, SecurityState>(
      bloc: security,
      builder: (context, state) => state.isBiometricsAvailable
          ? Column(children: [
              SwitchListTile.adaptive(
                  value: state.unlockWithBiometrics,
                  secondary:
                      Icon(Icons.fingerprint_rounded, color: Colors.black),
                  title: b.Badge(
                      showBadge: state.isUnsavedBiometrics,
                      padding: EdgeInsets.all(2.0),
                      alignment: Alignment.centerLeft,
                      position: b.BadgePosition.topEnd(),
                      child: Text(S.current.messageUnlockUsingBiometrics)),
                  onChanged: (useBiometrics) {
                    String authMode = useBiometrics
                        ? Constants.authModeVersion2
                        : state.newPassword.isNotEmpty
                            ? Constants.authModeManual
                            : state.currentAuthMode;

                    security.setNewAuthMode(authMode);
                    security.setUnlockWithBiometrics(useBiometrics);
                  }),
              Visibility(
                  visible: state.showRemoveBiometricsWarning,
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                      child: Text(S.current.messageAlertSaveCopyPassword,
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: Colors.red))))
            ])
          : SizedBox());

  Widget _saveChanges() => BlocBuilder<SecurityCubit, SecurityState>(
      bloc: security,
      builder: (context, state) => state.hasUnsavedChanges
          ? Container(
              padding: EdgeInsets.only(top: 30.0, right: 18.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    child: Text(S.current.actionSaveChanges),
                    onPressed: (() async {
                      final saveChanges =
                          await _confirmSaveChanges(context, state);

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
                    }))
              ]))
          : SizedBox());

  Future<void> _saveNoLocalPasswordChanges(SecurityState state) async {
    String? authMode = state.useBiometrics
        ? Constants.authModeVersion2
        : Constants.authModeManual;

    if (state.newPassword.isNotEmpty) {
      final changed =
          await security.changeRepositoryPassword(state.newPassword);

      if (changed == false) {
        final errorMessage = S.current.messageErrorAddingLocalPassword;
        showSnackBar(context, message: errorMessage);

        return;
      }

      security.setCurrentPassword(state.newPassword);
    }

    if (state.useBiometrics) {
      security.setCurrentUnlockWithBiometrics(true);
    }

    security.setNewAuthMode('');
    security.clearNewPassword();

    security.setCurrentAuthMode(authMode);
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
      final changed = await security.changeRepositoryPassword(password);

      if (changed == false) {
        final errorMessage = S.current.messageErrorChangingLocalPassword;
        showSnackBar(context, message: errorMessage);

        return;
      }
    }

    if (state.removePassword || state.useBiometrics) {
      final addedToSecureStorage =
          await security.addPasswordToSecureStorage(password, authMode);

      if (addedToSecureStorage == false) {
        showSnackBar(context, message: S.current.messageErrorRemovingPassword);

        return;
      }

      if (state.useBiometrics) {
        security.setCurrentUnlockWithBiometrics(true);
      }

      if (state.removePassword) {
        security.setRemovePassword(false);
      }
    }

    if (password != state.currentPassword) {
      security.setCurrentPassword(password);
    }

    if (authMode != state.currentAuthMode) {
      security.setCurrentAuthMode(authMode);
    }

    security.setNewAuthMode('');
    security.clearNewPassword();
  }

  Future<void> _saveBiometricChanges(SecurityState state) async {
    final authMode = state.useBiometrics
        ? Constants.authModeVersion2
        : state.newPassword.isEmpty
            ? Constants.authModeNoLocalPassword
            : Constants.authModeManual;

    if (state.newPassword.isNotEmpty) {
      final changed =
          await security.changeRepositoryPassword(state.newPassword);

      if (changed == false) {
        final errorMessage = S.current.messageErrorAddingSecureStorge;
        showSnackBar(context, message: errorMessage);

        return;
      }

      security.setCurrentPassword(state.newPassword);

      if (state.useBiometrics) {
        final updated = await security.updatePasswordInSecureStorage(
            state.newPassword, authMode);

        if (updated == false) {
          showSnackBar(context,
              message: S.current.messageErrorUpdatingSecureStorage);

          security.setCurrentUnlockWithBiometrics(false);
          security.setCurrentPassword(state.newPassword);
          security.setCurrentAuthMode(Constants.authModeManual);

          security.clearNewPassword();
          security.setNewAuthMode('');

          return;
        }
      }
    }

    if (state.useBiometrics == false) {
      if (state.newPassword.isNotEmpty) {
        final deleted = await security
            .removePasswordFromSecureStorage(state.currentAuthMode);

        if (deleted == false) {
          showSnackBar(context,
              message: S.current.messageErrorRemovingSecureStorage);

          security.setCurrentUnlockWithBiometrics(false);
          security.setCurrentPassword(state.newPassword);
          security.setCurrentAuthMode(Constants.authModeManual);

          security.clearNewPassword();
          security.setNewAuthMode('');

          return;
        }
      }

      security.setCurrentUnlockWithBiometrics(false);
    }

    security.setCurrentAuthMode(authMode);

    security.clearNewPassword();
    security.setNewAuthMode('');
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
