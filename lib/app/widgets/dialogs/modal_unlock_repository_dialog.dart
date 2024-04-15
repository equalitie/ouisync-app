import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/master_key.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';
import '../../cubits/cubits.dart';
import '../widgets.dart';

class UnlockRepository extends StatefulWidget {
  UnlockRepository({
    required this.repoCubit,
    required this.masterKey,
    required this.passwordHasher,
    required this.isBiometricsAvailable,
  });

  final RepoCubit repoCubit;
  final MasterKey masterKey;
  final PasswordHasher passwordHasher;
  final bool isBiometricsAvailable;

  @override
  State<UnlockRepository> createState() => _UnlockRepositoryState();
}

class _UnlockRepositoryState extends State<UnlockRepository> with AppLogger {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool store = false;
  bool secureWithBiometrics = false;
  bool passwordInvalid = false;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildPasswordField(context),
            buildStoreSwitch(),
            buildBiometricsSwitch(),
            Fields.dialogActions(context, buttons: buildActions(context)),
          ],
        ),
      );

  Widget buildPasswordField(BuildContext context) => Fields.formTextField(
        context: context,
        controller: passwordController,
        obscureText: obscurePassword,
        labelText: S.current.labelTypePassword,
        hintText: S.current.messageRepositoryPassword,
        errorText: passwordInvalid ? S.current.messageUnlockRepoFailed : null,
        suffixIcon: Fields.actionIcon(
          Icon(
            obscurePassword
                ? Constants.iconVisibilityOn
                : Constants.iconVisibilityOff,
            size: Dimensions.sizeIconSmall,
          ),
          color: Colors.black,
          onPressed: () => setState(() {
            obscurePassword = !obscurePassword;
          }),
        ),
        validator: validateNoEmptyMaybeRegExpr(
          emptyError: S.current.messageErrorRepositoryPasswordValidation,
        ),
        autofocus: true,
      );

  Widget buildStoreSwitch() => SwitchListTile.adaptive(
        value: store,
        title: Text(S.current.labelRememberPassword),
        onChanged: (value) => setState(() {
          store = value;
        }),
        contentPadding: EdgeInsets.zero,
      );

  Widget buildBiometricsSwitch() => Visibility(
        visible: widget.isBiometricsAvailable,
        child: SwitchListTile.adaptive(
          value: secureWithBiometrics,
          title: Text(S.current.messageSecureUsingBiometrics),
          onChanged: store
              ? (value) => setState(() {
                    secureWithBiometrics = value;
                  })
              : null,
          contentPadding: EdgeInsets.zero,
        ),
      );

  List<Widget> buildActions(context) => [
        NegativeButton(
          text: S.current.actionCancel,
          onPressed: () => Navigator.of(context).pop(null),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        ),
        PositiveButton(
          text: S.current.actionUnlock,
          onPressed: () => onSubmit(context),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        )
      ];

  Future<void> onSubmit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text.isEmpty) {
      return;
    }

    final password = LocalPassword(passwordController.text);

    await Dialogs.executeFutureWithLoadingDialog(
      context,
      f: widget.repoCubit.unlock(password),
    );

    final accessMode = widget.repoCubit.accessMode;

    if (accessMode == AccessMode.blind) {
      setState(() {
        passwordInvalid = true;
      });
      return;
    } else {
      setState(() {
        passwordInvalid = false;
      });
    }

    if (store) {
      await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: updateLocalSecretStore(password),
      );
    }

    Navigator.of(context).pop(UnlockRepositoryResult(
      repoLocation: widget.repoCubit.location,
      password: password,
      accessMode: accessMode,
      message: S.current.messageUnlockRepoOk(accessMode.name),
    ));
  }

  Future<void> updateLocalSecretStore(LocalPassword password) async {
    try {
      // NOTE: Using `!` is ok here because this only returns null when the repo is currently in
      // blind mode but we already covered that case earlier.
      final salt = (await widget.repoCubit.getCurrentModePasswordSalt())!;

      final keyAndSalt = await widget.passwordHasher.hashPassword(
        password,
        salt,
      );

      final authMode = await AuthModeKeyStoredOnDevice.encrypt(
        widget.masterKey,
        keyAndSalt.key,
        keyOrigin: SecretKeyOrigin.manual,
        secureWithBiometrics: secureWithBiometrics,
      );

      await widget.repoCubit.setAuthMode(authMode);
    } catch (e, st) {
      // TODO: Should we show this error to the user?

      loggy.error(
        'Failed to store local secret for repo ${widget.repoCubit.name}',
        e,
        st,
      );
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
