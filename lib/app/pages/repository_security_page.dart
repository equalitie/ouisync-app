import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../mixins/repo_actions_mixin.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class RepositorySecurity extends StatefulWidget {
  const RepositorySecurity({
    required this.repo,
    required this.currentSecret,
    required this.isBiometricsAvailable,
  });

  final RepoCubit repo;
  final LocalSecret currentSecret;
  final bool isBiometricsAvailable;

  @override
  State<RepositorySecurity> createState() =>
      _RepositorySecurityState(isBiometricsAvailable, repo, currentSecret);
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

  final bool _isBiometricsAvailable;
  final RepoCubit _repo;
  LocalSecret _currentSecret;

  PasswordMode get _passwordMode => _repo.repoSettings.passwordMode;

  _RepositorySecurityState(
      this._isBiometricsAvailable, this._repo, this._currentSecret);

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

  String get _passwordModeTitle => _passwordMode == PasswordMode.manual
      ? S.current.messageUpdateLocalPassword
      : S.current.messageAddLocalPassword;

  Widget _pasword() {
    return Container(
        padding: Dimensions.paddingDialog,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_passwordModeTitle),
          Dimensions.spacingVerticalDouble,
          PasswordValidation(
              passwordMode: _passwordMode,
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
      children: _passwordMode == PasswordMode.manual
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
                          f: _updateLocalPassword(LocalPassword(newPassword)));
                    },
                    text: S.current.actionUpdate,
                    size: Dimensions.sizeInPageButtonLong,
                    focusNode: _passwordAction)
              ])
            ]
          : [
              Fields.inPageButton(
                  onPressed: _passwordMode == PasswordMode.none
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
                              f: _addLocalPassword(LocalPassword(newPassword)));
                        }
                      : null,
                  text: S.current.actionCreate,
                  size: Dimensions.sizeInPageButtonLong,
                  focusNode: _passwordAction)
            ]);

  bool get _unlockWithBiometrics => _passwordMode == PasswordMode.bio;

  Widget _biometrics() => _isBiometricsAvailable
      ? Column(children: [
          SwitchListTile.adaptive(
              value: _unlockWithBiometrics,
              secondary: Icon(Icons.fingerprint_rounded, color: Colors.black),
              title: Text(S.current.messageUnlockUsingBiometrics,
                  style: context.theme.appTextStyle.bodyMedium),
              onChanged: (useBiometrics) async {
                final positiveButtonText = S.current.actionAccept;
                String confirmationMessage = useBiometrics
                    ? S.current.messageUnlockUsingBiometricsConfirmation
                    : S.current.messageRemoveBiometricsConfirmation;

                if (useBiometrics && _passwordMode == PasswordMode.manual) {
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
  Future<void> _addLocalPassword(LocalPassword newPassword) async {
    try {
      await _repo.repoSettings.setAuthModePasswordProvidedByUser();
    } catch (e) {
      showSnackBar(context,
          message: S.current.messageErrorRemovingSecureStorage);
      return;
    }

    final changed = await _changeRepositorySecret(newPassword);

    if (changed == false) {
      showSnackBar(context, message: S.current.messageErrorAddingLocalPassword);
      return;
    }

    _emitSecret(newPassword);
    _emitPasswordMode(PasswordMode.manual);

    _clearPasswordInputs();
  }

  // Returns error message on error.
  Future<void> _updateLocalPassword(LocalPassword newPassword) async {
    final changed = await _changeRepositorySecret(newPassword);

    if (changed == false) {
      showSnackBar(context, message: S.current.messageErrorAddingLocalPassword);
      return;
    }

    _emitSecret(newPassword);
  }

  void _clearPasswordInputs() {
    _passwordController.clear();
    _retypedPasswordController.clear();

    _passwordAction.requestFocus();
  }

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _removePassword() async {
    final newPassword = generateRandomPassword();

    final passwordChanged = await _changeRepositorySecret(newPassword);
    if (passwordChanged == false) {
      showSnackBar(context, message: S.current.messageErrorAddingSecureStorge);
      return;
    }

    try {
      await _repo.repoSettings
          .setAuthModeSecretStoredOnDevice(newPassword, false);
    } catch (e) {
      showSnackBar(context, message: S.current.messageErrorRemovingPassword);
      return;
    }

    _emitSecret(newPassword);
    _emitPasswordMode(PasswordMode.none);
  }

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _updateUnlockRepoWithBiometrics(
    bool unlockWithBiometrics,
  ) async {
    if (unlockWithBiometrics == false) {
      _emitPasswordMode(PasswordMode.none);
      return;
    }

    final newPassword = generateRandomPassword();
    final passwordChanged = await _changeRepositorySecret(newPassword);

    if (passwordChanged == false) {
      showSnackBar(context, message: S.current.messageErrorAddingSecureStorge);
      return;
    }

    try {
      await _repo.repoSettings.setAuthModeSecretStoredOnDevice(
        newPassword,
        unlockWithBiometrics,
      );
    } catch (e) {
      showSnackBar(context,
          message: S.current.messageErrorUpdatingSecureStorage);
      return;
    }

    _emitSecret(newPassword);
    _emitPasswordMode(PasswordMode.bio);

    _clearPasswordInputs();
  }

  Future<bool> _changeRepositorySecret(LocalSecret newSecret) async {
    return _repo.setSecret(
      oldSecret: _currentSecret,
      newSecret: newSecret,
    );
  }

  void _emitSecret(LocalSecret newSecret) => setState(() {
        _currentSecret = newSecret;
      });

  void _emitPasswordMode(PasswordMode passwordMode) => setState(() {
        _repo.emitPasswordMode(passwordMode);
      });
}
