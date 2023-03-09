import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../pages/main_page.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class UnlockRepository extends StatelessWidget with OuiSyncAppLogger {
  UnlockRepository(
      {Key? key,
      required this.context,
      required this.databaseId,
      required this.repositoryName,
      required this.isBiometricsAvailable,
      required this.isPasswordValidation,
      required this.unlockRepositoryCallback,
      required this.onSecureRepositoryWithBiometricsCallback})
      : super(key: key);

  final BuildContext context;
  final String databaseId;
  final String repositoryName;
  final bool isBiometricsAvailable;
  final bool isPasswordValidation;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Future<AccessMode?> Function(
      {required String repositoryName,
      required String password}) unlockRepositoryCallback;

  final SecureRepoWithBiometricsFunction
      onSecureRepositoryWithBiometricsCallback;

  final TextEditingController _passwordController =
      TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _useBiometrics = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildUnlockRepositoryWidget(this.context),
      );

  Widget _buildUnlockRepositoryWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText('"$repositoryName"',
              flex: 0, fontWeight: FontWeight.w400),
          Dimensions.spacingVerticalDouble,
          ValueListenableBuilder(
              valueListenable: _obscurePassword,
              builder: (context, value, child) {
                final obscure = value;
                return Row(children: [
                  Expanded(
                      child: Fields.formTextField(
                          context: context,
                          textEditingController: _passwordController,
                          obscureText: obscure,
                          label: S.current.labelTypePassword,
                          suffixIcon: Fields.actionIcon(
                              Icon(
                                obscure
                                    ? Constants.iconVisibilityOn
                                    : Constants.iconVisibilityOff,
                                size: Dimensions.sizeIconSmall,
                              ), onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          }),
                          hint: S.current.messageRepositoryPassword,
                          onSaved: (String? password) async {
                            await _unlockRepository(password);
                          },
                          validator: validateNoEmpty(
                              Strings.messageErrorRepositoryPasswordValidation),
                          autofocus: true))
                ]);
              }),
          if (!isPasswordValidation) _useBiometricsCheckbox(),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Widget _useBiometricsCheckbox() => ValueListenableBuilder(
      valueListenable: _useBiometrics,
      builder: (context, useBiometrics, child) {
        return Visibility(
            visible: isBiometricsAvailable,
            child: SwitchListTile.adaptive(
                value: useBiometrics,
                title: Text(S.current.messageSecureUsingBiometrics),
                onChanged: (enableBiometrics) {
                  _useBiometrics.value = enableBiometrics;
                },
                contentPadding: EdgeInsets.zero));
      });

  Future<void> _unlockRepository(String? password) async {
    if (password == null || password.isEmpty) {
      return;
    }

    final accessMode = await unlockRepositoryCallback(
        repositoryName: repositoryName, password: password);

    if ((accessMode ?? AccessMode.blind) == AccessMode.blind) {
      final notUnlockedResponse = UnlockRepositoryResult(
          repositoryName: repositoryName,
          password: password,
          accessMode: AccessMode.blind,
          message: S.current.messageUnlockRepoFailed);

      Navigator.of(context).pop(notUnlockedResponse);
      return;
    }

    assert(accessMode != null, 'Error: accessMode is null');

    // Only if the password successfuly unlocked the repo, then we add it
    // to the biometrics store -if the user selected the option.
    if (_useBiometrics.value) {
      final biometricsResult = await Dialogs.executeFutureWithLoadingDialog(
          context,
          f: SecureStorage.addRepositoryPassword(
              databaseId: databaseId,
              password: password,
              authenticationRequired: true));

      if (biometricsResult.exception != null) {
        loggy.app(biometricsResult.exception);
        return;
      }

      onSecureRepositoryWithBiometricsCallback.call(
          repositoryName: repositoryName, value: true);
    }

    final message = _useBiometrics.value
        ? S.current.messageBiometricValidationAdded(repositoryName)
        : S.current.messageUnlockRepoOk(accessMode!.name);

    final unlockedResponse = UnlockRepositoryResult(
        repositoryName: repositoryName,
        password: password,
        accessMode: accessMode!,
        message: message);

    Navigator.of(context).pop(unlockedResponse);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null)),
        PositiveButton(
            text: S.current.actionUnlock, onPressed: _validatePassword)
      ];

  void _validatePassword() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}

class UnlockRepositoryResult {
  UnlockRepositoryResult(
      {required this.repositoryName,
      required this.password,
      required this.accessMode,
      required this.message});

  final String repositoryName;
  final String password;
  final AccessMode accessMode;
  final String message;
}
