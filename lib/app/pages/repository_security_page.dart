import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../mixins/repo_actions_mixin.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class RepositorySecurityPage extends StatefulWidget {
  static Future<RepositorySecurityPage> create({
    required Settings settings,
    required RepoCubit repo,
    required LocalSecret currentSecret,
    required PasswordHasher passwordHasher,
  }) async {
    final isBiometricsAvailable = await LocalAuth.canAuthenticate();

    return RepositorySecurityPage._(
      settings: settings,
      repo: repo,
      currentSecret: currentSecret,
      isBiometricsAvailable: isBiometricsAvailable,
      passwordHasher: passwordHasher,
    );
  }

  const RepositorySecurityPage._({
    required this.settings,
    required this.repo,
    required this.currentSecret,
    required this.isBiometricsAvailable,
    required this.passwordHasher,
  });

  final Settings settings;
  final RepoCubit repo;
  final LocalSecret currentSecret;
  final bool isBiometricsAvailable;
  final PasswordHasher passwordHasher;

  @override
  State<RepositorySecurityPage> createState() =>
      _RepositorySecurityState(currentSecret);
}

class _RepositorySecurityState extends State<RepositorySecurityPage>
    with AppLogger, RepositoryActionsMixin {
  final FocusNode _passwordAction = FocusNode(debugLabel: 'password_input');

  bool _useCustomPassword = false;
  String? _validPassword;
  bool _storeUserPasswordAsKey = true;

  LocalSecret _currentSecret;

  PasswordMode get _passwordMode => widget.repo.state.authMode.passwordMode;

  _RepositorySecurityState(this._currentSecret);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.current.titleSecurity), elevation: 0.0),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: Dimensions.paddingDialog,
              child: Text("Reset local secret", style: AppTypography.titleBig)),
          _buildUseCustomPasswordSwitch(),
          _paswordInput(),
          _submitButton(),
          Dimensions.spacingVertical,
          Divider(height: 30.0),
          _biometrics()
        ])));
  }

  Widget _paswordInput() {
    if (_useCustomPassword) {
      return Container(
          padding: Dimensions.paddingDialog,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Dimensions.spacingVerticalDouble,
            PasswordValidation(
                onPasswordChange: (password) =>
                    setState(() => _validPassword = password)),
            _buildStoreUserPassworAsKey(),
          ]));
    } else {
      return SizedBox();
    }
  }

  Widget _submitButton() => Container(
        padding: Dimensions.paddingDialog,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Fields.inPageButton(
              onPressed: (_useCustomPassword ? _validPassword != null : true)
                  ? () async {
                      if (_useCustomPassword) {
                        final password = _validPassword;
                        if (password == null) return;

                        if (!await _confirmSaveChanges(context)) return;

                        await Dialogs.executeFutureWithLoadingDialog(context,
                            f: _submitPassword(LocalPassword(password),
                                _storeUserPasswordAsKey));
                      } else {
                        if (!await _confirmSaveChanges(context)) return;

                        await Dialogs.executeFutureWithLoadingDialog(context,
                            f: _submitGenerateKey());
                      }
                    }
                  : null,
              text: S.current.actionResetSecret,
              size: Dimensions.sizeInPageButtonLong,
              focusNode: _passwordAction)
        ]),
      );

  Widget _buildRowWithSwitch(
          {required bool value,
          required IconData icon,
          required String text,
          required void Function(bool) onChange}) =>
      SwitchListTile.adaptive(
          value: value,
          secondary: Icon(icon, color: Colors.black),
          title: Text(text, style: context.theme.appTextStyle.bodyMedium),
          onChanged: onChange);

  Widget _buildStoreUserPassworAsKey() => _buildRowWithSwitch(
      value: _storeUserPasswordAsKey,
      icon: Icons.account_balance,
      text: S.current.actionStoreSecretOnDevice,
      onChange: (bool value) =>
          setState(() => _storeUserPasswordAsKey = value));

  Widget _buildUseCustomPasswordSwitch() => _buildRowWithSwitch(
      value: _useCustomPassword,
      icon: Icons.password_outlined,
      text: S.current.actionUseCustomLocalPassword,
      onChange: (bool value) => setState(() => _useCustomPassword = value));

  Widget _biometrics() =>
      (widget.isBiometricsAvailable && _passwordMode != PasswordMode.manual)
          ? _buildRowWithSwitch(
              value: _passwordMode == PasswordMode.bio,
              icon: Icons.fingerprint_rounded,
              text: S.current.messageUnlockUsingBiometrics,
              onChange: (useBiometrics) async {
                await Dialogs.executeFutureWithLoadingDialog(context,
                    f: _updateUnlockRepoWithBiometrics(useBiometrics));
              })
          : SizedBox();

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _submitPassword(LocalPassword newPassword, bool store) async {
    final salt = PasswordSalt.random();
    final key = await widget.passwordHasher.hashPassword(newPassword, salt);
    final newSecret = LocalSecretKeyAndSalt(key, salt);

    try {
      if (store) {
        final authMode = await AuthModeKeyStoredOnDevice.encrypt(
          widget.settings.masterKey,
          key,
          confirmWithBiometrics: _passwordMode == PasswordMode.bio,
        );

        await widget.repo.setAuthMode(authMode);
      } else {
        final authMode = AuthModeBlindOrManual();
        await widget.repo.setAuthMode(authMode);
      }
    } catch (e) {
      showSnackBar(S.current.messageErrorRemovingSecureStorage);
      return;
    }

    final changed = await _changeRepositorySecret(newSecret);

    if (!changed) {
      showSnackBar(S.current.messageErrorAddingLocalPassword);
      return;
    }

    _emitSecret(newSecret.key);

    // TODO
    //_clearPasswordInputs();
  }

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _submitGenerateKey() async {
    final newSecret = LocalSecretKeyAndSalt.random();

    final passwordChanged = await _changeRepositorySecret(newSecret);
    if (passwordChanged == false) {
      showSnackBar(S.current.messageErrorAddingSecureStorge);
      return;
    }

    try {
      final authMode = await AuthModeKeyStoredOnDevice.encrypt(
        widget.settings.masterKey,
        newSecret.key,
        confirmWithBiometrics: _passwordMode == PasswordMode.bio,
      );
      await widget.repo.setAuthMode(authMode);
    } catch (e) {
      showSnackBar(S.current.messageErrorRemovingPassword);
      return;
    }

    _emitSecret(newSecret.key);
  }

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _updateUnlockRepoWithBiometrics(
    bool unlockWithBiometrics,
  ) async {
    try {
      await widget.repo.setConfirmWithBiometrics(unlockWithBiometrics);
    } catch (e) {
      showSnackBar(S.current.messageErrorUpdatingSecureStorage);
    }
  }

  Future<bool> _changeRepositorySecret(SetLocalSecret newSecret) async {
    return widget.repo.setSecret(
      oldSecret: _currentSecret,
      newSecret: newSecret,
    );
  }

  void _emitSecret(LocalSecret newSecret) => setState(() {
        _currentSecret = newSecret;
      });

  Future<bool> _confirmSaveChanges(BuildContext context) async {
    final positiveButtonText = S.current.actionResetSecret;
    final message = S.current.messageConfirmIrreversibleChange;

    final saveChanges = await Dialogs.alertDialogWithActions(
        context: context,
        title: S.current.titleSaveChanges,
        body: [
          Text(message, style: context.theme.appTextStyle.bodyMedium)
        ],
        actions: [
          TextButton(
              child: Text(S.current.actionCancel.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(false)),
          TextButton(
              child: Text(positiveButtonText.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(true))
        ]);

    return saveChanges ?? false;
  }
}
