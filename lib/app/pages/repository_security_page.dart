import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../mixins/repo_actions_mixin.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class RepositorySecurity extends StatefulWidget {
  const RepositorySecurity({
    required this.repo,
    required this.password,
    required this.isBiometricsAvailable,
  });

  final RepoCubit repo;
  final String password;
  final bool isBiometricsAvailable;

  @override
  State<RepositorySecurity> createState() =>
      _RepositorySecurityState(isBiometricsAvailable, repo, password);
}

class _RepositorySecurityState extends State<RepositorySecurity>
    with AppLogger, RepositoryActionsMixin {
  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  final TextEditingController _passwordController =
      TextEditingController(text: null);
  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

  final FocusNode _passwordAction = FocusNode(debugLabel: 'password_input');

  final bool isBiometricsAvailable;
  final RepoCubit repo;
  String password;

  PasswordMode get passwordMode => repo.repoSettings.passwordMode;

  _RepositorySecurityState(
      this.isBiometricsAvailable, this.repo, this.password);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(S.current.titleSecurity), elevation: 0.0),
      body: SingleChildScrollView(
          child: Container(
              child: Column(children: [
        _pasword(),
        Divider(height: 30.0),
        _biometrics()
      ]))));

  String get passwordModeTitle => passwordMode == PasswordMode.manual
      ? S.current.messageUpdateLocalPassword
      : S.current.messageAddLocalPassword;

  Widget _pasword() {
    return Container(
        padding: Dimensions.paddingDialog,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(passwordModeTitle),
          Dimensions.spacingVerticalDouble,
          PasswordValidation(
              passwordMode: passwordMode,
              passwordInputKey: _passwordInputKey,
              retypePasswordInputKey: _retypePasswordInputKey,
              passwordController: _passwordController,
              retypedPasswordController: _retypedPasswordController,
              actions: _passwordActions),
          Dimensions.spacingVertical
        ]));
  }

  Widget _passwordActions() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: passwordMode == PasswordMode.manual
          ? [
              Row(children: [
                TextButton(
                    focusNode: _passwordAction,
                    child: Text(S.current.actionRemoveLocalPassword,
                        style: context.theme.appTextStyle.bodyMedium
                            .copyWith(color: Constants.dangerColor)),
                    onPressed: () async {
                      final positiveButtonText = S.current.actionRemove;
                      final confirmationMessage =
                          S.current.messageRemoveLocalPasswordConfirmation;

                      final saveChanges = await confirmSaveChanges(
                        context,
                        positiveButtonText,
                        confirmationMessage,
                      );

                      if (saveChanges == null || !saveChanges) return;

                      await Dialogs.executeFutureWithLoadingDialog(context,
                          f: _removePassword());
                    })
              ]),
              Dimensions.spacingVertical,
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Fields.inPageButton(
                    onPressed: () async {
                      final password = _retypedPasswordController.text;
                      if (password.isEmpty) return;

                      final newPassword = validatePassword(password,
                          passwordInputKey: _passwordInputKey,
                          retypePasswordInputKey: _retypePasswordInputKey);

                      if (newPassword == null) return;

                      final positiveButtonText = S.current.actionUpdate;
                      final confirmationMessage =
                          S.current.messageUpdateLocalPasswordConfirmation;

                      final saveChanges = await confirmSaveChanges(
                          context, positiveButtonText, confirmationMessage);

                      if (saveChanges == null || !saveChanges) return;

                      await Dialogs.executeFutureWithLoadingDialog(context,
                          f: _updateLocalPassword(newPassword));
                    },
                    text: S.current.actionUpdate,
                    size: Dimensions.sizeInPageButtonLong,
                    focusNode: _passwordAction)
              ])
            ]
          : [
              Fields.inPageButton(
                  onPressed: passwordMode == PasswordMode.none
                      ? () async {
                          final password = _retypedPasswordController.text;
                          if (password.isEmpty) return;

                          final newPassword = validatePassword(password,
                              passwordInputKey: _passwordInputKey,
                              retypePasswordInputKey: _retypePasswordInputKey);

                          if (newPassword == null) return;

                          final positiveButtonText = S.current.actionAdd;
                          final confirmationMessage =
                              S.current.messageAddLocalPasswordConfirmation;

                          final saveChanges = await confirmSaveChanges(
                              context, positiveButtonText, confirmationMessage);

                          if (saveChanges == null || !saveChanges) return;

                          _passwordController.clear();
                          _retypedPasswordController.clear();

                          await Dialogs.executeFutureWithLoadingDialog(context,
                              f: _addLocalPassword(newPassword));
                        }
                      : null,
                  text: S.current.actionCreate,
                  size: Dimensions.sizeInPageButtonLong,
                  focusNode: _passwordAction)
            ]);

  bool get unlockWithBiometrics => passwordMode == PasswordMode.bio;

  Widget _biometrics() => isBiometricsAvailable
      ? Column(children: [
          SwitchListTile.adaptive(
              value: unlockWithBiometrics,
              secondary: Icon(Icons.fingerprint_rounded, color: Colors.black),
              title: Text(S.current.messageUnlockUsingBiometrics,
                  style: context.theme.appTextStyle.bodyMedium),
              onChanged: (useBiometrics) async {
                final positiveButtonText = S.current.actionAccept;
                String confirmationMessage = useBiometrics
                    ? S.current.messageUnlockUsingBiometricsConfirmation
                    : S.current.messageRemoveBiometricsConfirmation;

                if (useBiometrics && passwordMode == PasswordMode.manual) {
                  confirmationMessage +=
                      '\n\n${S.current.messageRemoveBiometricsConfirmationMoreInfo}.';
                }

                final saveChanges = await confirmSaveChanges(
                    context, positiveButtonText, confirmationMessage);

                if (saveChanges == null || !saveChanges) return;

                await Dialogs.executeFutureWithLoadingDialog(context,
                    f: _updateUnlockRepoWithBiometrics(useBiometrics));
              })
        ])
      : SizedBox();

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _addLocalPassword(String newPassword) async {
    try {
      await repo.repoSettings.setAuthModePasswordProvidedByUser();
    } catch (e) {
      showSnackBar(context,
          message: S.current.messageErrorRemovingSecureStorage);
      return;
    }

    final changed = await _changeRepositoryPassword(newPassword);

    if (changed == false) {
      showSnackBar(context, message: S.current.messageErrorAddingLocalPassword);
      return;
    }

    emitPassword(newPassword);
    emitPasswordMode(PasswordMode.manual);

    _clearPasswordInputs();
  }

  // Returns error message on error.
  Future<void> _updateLocalPassword(String newPassword) async {
    final changed = await _changeRepositoryPassword(newPassword);

    if (changed == false) {
      showSnackBar(context, message: S.current.messageErrorAddingLocalPassword);
      return;
    }

    emitPassword(newPassword);
  }

  void _clearPasswordInputs() {
    _passwordController.clear();
    _retypedPasswordController.clear();

    _passwordAction.requestFocus();
  }

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _removePassword() async {
    final newPassword = generateRandomPassword();

    final passwordChanged = await _changeRepositoryPassword(newPassword);
    if (passwordChanged == false) {
      showSnackBar(context, message: S.current.messageErrorAddingSecureStorge);
      return;
    }

    try {
      await repo.repoSettings
          .setAuthModePasswordStoredOnDevice(LocalPassword(newPassword), false);
    } catch (e) {
      showSnackBar(context, message: S.current.messageErrorRemovingPassword);
      return;
    }

    emitPassword(newPassword);
    emitPasswordMode(PasswordMode.none);
  }

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _updateUnlockRepoWithBiometrics(
    bool unlockWithBiometrics,
  ) async {
    if (unlockWithBiometrics == false) {
      emitPasswordMode(PasswordMode.none);
      return;
    }

    final newPassword = generateRandomPassword();
    final passwordChanged = await _changeRepositoryPassword(newPassword);

    if (passwordChanged == false) {
      showSnackBar(context, message: S.current.messageErrorAddingSecureStorge);
      return;
    }

    try {
      await repo.repoSettings.setAuthModePasswordStoredOnDevice(
        LocalPassword(newPassword),
        unlockWithBiometrics,
      );
    } catch (e) {
      showSnackBar(context,
          message: S.current.messageErrorUpdatingSecureStorage);
      return;
    }

    emitPassword(newPassword);
    emitPasswordMode(PasswordMode.bio);

    _clearPasswordInputs();
  }

  Future<bool> _changeRepositoryPassword(String newPassword) async {
    assert(password.isNotEmpty, 'ERROR: currentPassword is empty');

    if (password.isEmpty) {
      return false;
    }

    return repo.setPassword(
      oldPassword: password,
      newPassword: newPassword,
    );
  }

  void emitPassword(String newPassword) => setState(() {
        password = newPassword;
      });

  void emitPasswordMode(PasswordMode passwordMode) => setState(() {
        repo.emitPasswordMode(passwordMode);
      });
}
