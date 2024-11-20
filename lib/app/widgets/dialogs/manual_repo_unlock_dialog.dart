import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../../../generated/l10n.dart';
import '../../pages/repo_reset_access.dart';
import '../../widgets/dialogs/actions_dialog.dart';
import '../../utils/utils.dart'
    show
        AccessModeLocalizedExtension,
        AppLogger,
        Constants,
        Dialogs,
        Dimensions,
        Fields,
        MasterKey,
        Settings,
        validateNoEmptyMaybeRegExpr;
import '../../models/models.dart'
    show AuthModeKeyStoredOnDevice, RepoLocation, SecretKeyOrigin;
import '../../models/access_mode.dart';
import '../../cubits/cubits.dart' show RepoCubit;
import '../widgets.dart'
    show NegativeButton, PositiveButton, LinkStyleAsyncButton;

class ManualRepoUnlockDialog extends StatefulWidget {
  ManualRepoUnlockDialog({
    required this.repoCubit,
    required this.settings,
  });

  final RepoCubit repoCubit;
  final Settings settings;

  static Future<UnlockRepositoryResult?> show(
    BuildContext context,
    RepoCubit repoCubit,
    Settings settings,
  ) async {
    return await showDialog<UnlockRepositoryResult?>(
      context: context,
      builder: (BuildContext context) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ActionsDialog(
            title: S.current.messageUnlockRepository(repoCubit.name),
            body: ManualRepoUnlockDialog(
              repoCubit: repoCubit,
              settings: settings,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<ManualRepoUnlockDialog> createState() => _State();
}

class _State extends State<ManualRepoUnlockDialog> with AppLogger {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
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
            _buildIDontHaveLocalPasswordButton(context),
            Fields.dialogActions(buttons: buildActions(context)),
          ],
        ),
      );

  Widget _buildIDontHaveLocalPasswordButton(BuildContext context) {
    return LinkStyleAsyncButton(
        // TODO(inetic): locales
        text: "\nI don't have a local password for this repository\n",
        onTap: () async {
          final localSecret = await RepoResetAccessPage.show(
              context, widget.repoCubit, widget.settings);

          if (localSecret == null) {
            return;
          }

          switch (widget.repoCubit.state.accessMode) {
            case AccessMode.blind:
              return;
            case AccessMode.read:
              Navigator.of(context).maybePop(UnlockRepositoryResult(
                unlockedAccessMode: ReadAccessMode(),
                localSecret: localSecret,
              ));
            case AccessMode.write:
              Navigator.of(context).maybePop(UnlockRepositoryResult(
                unlockedAccessMode: WriteAccessMode(),
                localSecret: localSecret,
              ));
          }
        });
  }

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

  List<Widget> buildActions(context) => [
        NegativeButton(
          text: S.current.actionCancel,
          onPressed: () async => await Navigator.of(context).maybePop(null),
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
      widget.repoCubit.unlock(password),
    );

    final accessMode = widget.repoCubit.accessMode;
    UnlockedAccessMode unlockedAccessMode;

    switch (accessMode) {
      case AccessMode.blind:
        setState(() {
          passwordInvalid = true;
        });
        return;
      case AccessMode.read:
        unlockedAccessMode = ReadAccessMode();
      case AccessMode.write:
        unlockedAccessMode = WriteAccessMode();
    }

    setState(() {
      passwordInvalid = false;
    });

    Navigator.of(context).pop(UnlockRepositoryResult(
      unlockedAccessMode: unlockedAccessMode,
      localSecret: password,
    ));
  }
}

class UnlockRepositoryResult {
  final UnlockedAccessMode unlockedAccessMode;
  final LocalSecret localSecret;

  UnlockRepositoryResult(
      {required this.unlockedAccessMode, required this.localSecret});
}
