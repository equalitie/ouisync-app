import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';
import '../widgets.dart';

class UnlockRepository extends StatelessWidget with AppLogger {
  UnlockRepository({
    required this.parentContext,
    required this.databaseId,
    required this.repoLocation,
    required this.isBiometricsAvailable,
    required this.isPasswordValidation,
    required this.settings,
    required this.unlockRepositoryCallback,
  });

  final BuildContext parentContext;
  final DatabaseId databaseId;
  final RepoLocation repoLocation;
  final bool isBiometricsAvailable;
  final bool isPasswordValidation;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Settings settings;
  final Future<AccessMode?> Function(RepoLocation, LocalPassword)
      unlockRepositoryCallback;

  final TextEditingController _passwordController =
      TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _useBiometrics = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildUnlockRepositoryWidget(parentContext),
      );

  Widget _buildUnlockRepositoryWidget(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w400);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText('"${repoLocation.name}"',
              flex: 0, style: bodyStyle),
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
                                  size: Dimensions.sizeIconSmall),
                              color: Colors.black, onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          }),
                          hint: S.current.messageRepositoryPassword,
                          onSaved: (String? password) async {
                            await _unlockRepository(password);
                          },
                          validator: validateNoEmptyMaybeRegExpr(
                              emptyError: S.current
                                  .messageErrorRepositoryPasswordValidation),
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

  Future<void> _unlockRepository(String? passwordStr) async {
    if (passwordStr == null || passwordStr.isEmpty) {
      return;
    }

    final password = LocalPassword(passwordStr);

    final accessMode = await Dialogs.executeFutureWithLoadingDialog(
        parentContext,
        f: unlockRepositoryCallback(repoLocation, password));

    if ((accessMode ?? AccessMode.blind) == AccessMode.blind) {
      final notUnlockedResponse = UnlockRepositoryResult(
          repoLocation: repoLocation,
          password: password,
          accessMode: AccessMode.blind,
          message: S.current.messageUnlockRepoFailed);

      Navigator.of(parentContext).pop(notUnlockedResponse);
      return;
    }

    assert(accessMode != null, 'Error: accessMode is null');

    // Only if the password successfuly unlocked the repo, then we add it
    // to the secure storage -if the user selected the option.
    // TODO: Why are we storing the password from inside this UnlockRepository
    // dialog? And why are we doing it only when `_useBiometrics.value` is
    // true?
    if (_useBiometrics.value) {
      final success = await Dialogs.executeFutureWithLoadingDialog<bool>(
        parentContext,
        f: () async {
          try {
            await settings
                .repoSettingsById(databaseId)!
                .setAuthModeSecretStoredOnDevice(
                  password,
                  _useBiometrics.value,
                );
            return true;
          } catch (e, st) {
            // TODO: The user should learn about the failure.
            loggy.error('Failed to store password for repo $databaseId', e, st);
            return false;
          }
        }(),
      );

      if (!success) {
        return;
      }
    }

    final message = _useBiometrics.value
        ? S.current.messageBiometricValidationAdded(repoLocation.name)
        : S.current.messageUnlockRepoOk(accessMode!.name);

    final unlockedResponse = UnlockRepositoryResult(
        repoLocation: repoLocation,
        password: password,
        accessMode: accessMode!,
        message: message);

    Navigator.of(parentContext).pop(unlockedResponse);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionUnlock,
            onPressed: _validatePassword,
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
      ];

  void _validatePassword() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}

class UnlockRepositoryResult {
  UnlockRepositoryResult(
      {required this.repoLocation,
      required this.password,
      required this.accessMode,
      required this.message});

  final RepoLocation repoLocation;
  final LocalPassword password;
  final AccessMode accessMode;
  final String message;
}
