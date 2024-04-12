import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/repo.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class UnlockDialog<T> extends StatelessWidget with AppLogger {
  UnlockDialog({super.key, required this.context, required this.repository});

  final BuildContext context;
  final RepoCubit repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController =
      TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildUnlockRepositoryWidget(this.context),
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
          Fields.constrainedText('"${repository.name}"',
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
                          controller: _passwordController,
                          obscureText: obscure,
                          labelText: S.current.labelTypePassword,
                          hintText: S.current.messageRepositoryPassword,
                          suffixIcon: Fields.actionIcon(
                              Icon(
                                obscure
                                    ? Constants.iconVisibilityOn
                                    : Constants.iconVisibilityOff,
                                size: Dimensions.sizeIconSmall,
                              ),
                              color: Colors.black, onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          }),
                          onSaved: (String? password) async =>
                              await _validatePasswordAndReturn(password),
                          validator: validateNoEmptyMaybeRegExpr(
                              emptyError: S.current
                                  .messageErrorRepositoryPasswordValidation),
                          autofocus: true))
                ]);
              }),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Future<void> _validatePasswordAndReturn(String? password) async {
    if (password == null || password.isEmpty) {
      return;
    }

    Navigator.of(context).pop(password);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionUnlock,
            onPressed: _validatePasswordForm,
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
      ];

  void _validatePasswordForm() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}
