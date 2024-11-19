import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../../../generated/l10n.dart';
import '../../cubits/repo.dart' show RepoCubit;
import '../../utils/utils.dart'
    show AppLogger, Constants, Dimensions, Fields, validateNoEmptyMaybeRegExpr;
import '../widgets.dart' show NegativeButton, PositiveButton;

class UnlockDialog extends StatefulWidget {
  UnlockDialog(this.repoCubit, {super.key});

  final RepoCubit repoCubit;

  @override
  State<UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<UnlockDialog> with AppLogger {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool passwordInvalid = false;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: buildContent(context),
      );

  Widget buildContent(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText(
            '"${widget.repoCubit.name}"',
            flex: 0,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w400),
          ),
          Dimensions.spacingVerticalDouble,
          Fields.formTextField(
            context: context,
            controller: passwordController,
            obscureText: obscurePassword,
            labelText: S.current.labelTypePassword,
            hintText: S.current.messageRepositoryPassword,
            errorText:
                passwordInvalid ? S.current.messageUnlockRepoFailed : null,
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
          ),
          Fields.dialogActions(buttons: buildActions(context)),
        ],
      );

  List<Widget> buildActions(BuildContext context) => [
        NegativeButton(
          text: S.current.actionCancel,
          onPressed: () async => await Navigator.of(context).maybePop(''),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        ),
        PositiveButton(
          text: S.current.actionUnlock,
          onPressed: onSubmit,
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        ),
      ];

  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final password = passwordController.text;
    final accessMode = await widget.repoCubit.getPasswordAccessMode(password);

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

    Navigator.of(context).pop(password);
  }
}
