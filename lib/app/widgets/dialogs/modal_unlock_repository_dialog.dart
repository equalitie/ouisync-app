import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/master_key.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';
import '../../cubits/cubits.dart';
import '../widgets.dart';

class UnlockRepository extends StatelessWidget with AppLogger {
  UnlockRepository({
    required this.parentContext,
    required this.repoCubit,
    required this.masterKey,
    required this.passwordHasher,
    required this.isBiometricsAvailable,
    required this.isPasswordValidation,
  });

  final BuildContext parentContext;
  final RepoCubit repoCubit;
  final MasterKey masterKey;
  final PasswordHasher passwordHasher;
  final bool isBiometricsAvailable;
  final bool isPasswordValidation;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
          Fields.constrainedText(
            '"${repoCubit.name}"',
            flex: 0,
            style: bodyStyle,
          ),
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

    await Dialogs.executeFutureWithLoadingDialog(
      parentContext,
      f: repoCubit.unlock(password),
    );

    final accessMode = repoCubit.accessMode;

    if (accessMode == AccessMode.blind) {
      final notUnlockedResponse = UnlockRepositoryResult(
        repoLocation: repoCubit.location,
        password: password,
        accessMode: accessMode,
        message: S.current.messageUnlockRepoFailed,
      );

      Navigator.of(parentContext).pop(notUnlockedResponse);
      return;
    }

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
            final salt = (await repoCubit.getCurrentModePasswordSalt())!;
            final key = await passwordHasher.hashPassword(password, salt);
            final authMode = await AuthModeKeyStoredOnDevice.encrypt(
              masterKey,
              key,
              keyProvenance: SecretKeyProvenance.manual,
              confirmWithBiometrics: _useBiometrics.value,
            );

            await repoCubit.setAuthMode(authMode);
            return true;
          } catch (e, st) {
            // TODO: The user should learn about the failure.
            loggy.error(
              'Failed to store password for repo ${repoCubit.name}',
              e,
              st,
            );
            return false;
          }
        }(),
      );

      if (!success) {
        return;
      }
    }

    final message = _useBiometrics.value
        ? S.current.messageBiometricValidationAdded(repoCubit.name)
        : S.current.messageUnlockRepoOk(accessMode.name);

    final unlockedResponse = UnlockRepositoryResult(
        repoLocation: repoCubit.location,
        password: password,
        accessMode: accessMode,
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
