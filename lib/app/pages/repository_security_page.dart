import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../mixins/repo_actions_mixin.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class RepositorySecurityPage extends StatefulWidget {
  const RepositorySecurityPage({
    required this.settings,
    required this.repo,
    required this.currentSecret,
    required this.passwordHasher,
  });

  final Settings settings;
  final RepoCubit repo;
  final LocalSecret currentSecret;
  final PasswordHasher passwordHasher;

  @override
  State<RepositorySecurityPage> createState() => _RepositorySecurityState();
}

class _RepositorySecurityState extends State<RepositorySecurityPage>
    with AppLogger, RepositoryActionsMixin {
  final FocusNode passwordAction = FocusNode(debugLabel: 'password_input');

  bool useCustomPassword = false;
  String? validPassword;
  bool storeUserPasswordAsKey = true;

  bool isBiometricsAvailable = false;
  late LocalSecret currentSecret;

  AuthMode get authMode => widget.repo.state.authMode;

  @override
  void initState() {
    super.initState();

    currentSecret = widget.currentSecret;

    unawaited(LocalAuth.canAuthenticate().then(
      (value) => setState(() {
        isBiometricsAvailable = value;
      }),
    ));
  }

  @override
  void didUpdateWidget(RepositorySecurityPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    currentSecret = widget.currentSecret;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.current.titleSecurity), elevation: 0.0),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: Dimensions.paddingDialog,
            child: Text(
              S.current.messageResetLocalSecret,
              style: AppTypography.titleBig,
            ),
          ),
          _buildUseCustomPasswordSwitch(),
          _paswordInput(),
          _submitButton(),
          Dimensions.spacingVertical,
          Divider(height: 30.0),
          _biometrics()
        ])));
  }

  Widget _paswordInput() {
    if (useCustomPassword) {
      return Container(
          padding: Dimensions.paddingDialog,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Dimensions.spacingVerticalDouble,
            PasswordValidation(
                onPasswordChange: (password) =>
                    setState(() => validPassword = password)),
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
              onPressed: (useCustomPassword ? validPassword != null : true)
                  ? () async {
                      if (useCustomPassword) {
                        final password = validPassword;
                        if (password == null) return;

                        if (!await _confirmSaveChanges(context)) return;

                        await Dialogs.executeFutureWithLoadingDialog(context,
                            f: _submitPassword(LocalPassword(password),
                                storeUserPasswordAsKey));
                      } else {
                        if (!await _confirmSaveChanges(context)) return;

                        await Dialogs.executeFutureWithLoadingDialog(context,
                            f: _submitGenerateKey());
                      }
                    }
                  : null,
              text: S.current.actionResetSecret,
              size: Dimensions.sizeInPageButtonLong,
              focusNode: passwordAction)
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
      value: storeUserPasswordAsKey,
      icon: Icons.account_balance,
      text: S.current.actionStoreSecretOnDevice,
      onChange: (bool value) => setState(() => storeUserPasswordAsKey = value));

  Widget _buildUseCustomPasswordSwitch() => _buildRowWithSwitch(
      value: useCustomPassword,
      icon: Icons.password_outlined,
      text: S.current.actionUseCustomLocalPassword,
      onChange: (bool value) => setState(() => useCustomPassword = value));

  Widget _biometrics() => switch (authMode) {
        AuthModeKeyStoredOnDevice(confirmWithBiometrics: final value) ||
        AuthModePasswordStoredOnDevice(confirmWithBiometrics: final value)
            when isBiometricsAvailable =>
          _buildRowWithSwitch(
              value: value,
              icon: Icons.fingerprint_rounded,
              text: S.current.messageUnlockUsingBiometrics,
              onChange: (useBiometrics) async {
                await Dialogs.executeFutureWithLoadingDialog(context,
                    f: _updateUnlockRepoWithBiometrics(useBiometrics));
              }),
        AuthModeKeyStoredOnDevice() ||
        AuthModePasswordStoredOnDevice() ||
        AuthModeBlindOrManual() =>
          SizedBox(),
      };

  // TODO: If any of the async functions here fail, the user may lose their data.
  Future<void> _submitPassword(LocalPassword newPassword, bool store) async {
    final salt = PasswordSalt.random();
    final key = await widget.passwordHasher.hashPassword(newPassword, salt);
    final newSecret = LocalSecretKeyAndSalt(key, salt);

    try {
      if (store) {
        final newAuthMode = await AuthModeKeyStoredOnDevice.encrypt(
          widget.settings.masterKey,
          key,
          keyProvenance: SecretKeyProvenance.manual,
          confirmWithBiometrics: switch (authMode) {
            AuthModeKeyStoredOnDevice(confirmWithBiometrics: true) ||
            AuthModePasswordStoredOnDevice(confirmWithBiometrics: true) =>
              true,
            AuthModeKeyStoredOnDevice() ||
            AuthModePasswordStoredOnDevice() ||
            AuthModeBlindOrManual() =>
              false,
          },
        );

        await widget.repo.setAuthMode(newAuthMode);
      } else {
        final newAuthMode = AuthModeBlindOrManual();
        await widget.repo.setAuthMode(newAuthMode);
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
      final newAuthMode = await AuthModeKeyStoredOnDevice.encrypt(
        widget.settings.masterKey,
        newSecret.key,
        keyProvenance: SecretKeyProvenance.random,
        confirmWithBiometrics: switch (authMode) {
          AuthModeKeyStoredOnDevice(confirmWithBiometrics: true) ||
          AuthModePasswordStoredOnDevice(confirmWithBiometrics: true) =>
            true,
          AuthModeKeyStoredOnDevice() ||
          AuthModePasswordStoredOnDevice() ||
          AuthModeBlindOrManual() =>
            false,
        },
      );

      await widget.repo.setAuthMode(newAuthMode);
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
      oldSecret: currentSecret,
      newSecret: newSecret,
    );
  }

  void _emitSecret(LocalSecret newSecret) => setState(() {
        currentSecret = newSecret;
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
