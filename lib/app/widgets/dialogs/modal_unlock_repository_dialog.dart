import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class UnlockRepository extends StatelessWidget {
  UnlockRepository({
    Key? key,
    required this.context,
    required this.formKey,
    required this.repositoryName
  }) : super(key: key);

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final String repositoryName;

  final TextEditingController _passwordController = TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildUnlockRepositoryWidget(this.context),
    );
  }

  Widget _buildUnlockRepositoryWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Fields.constrainedText(
          '"$repositoryName"',
          flex: 0,
          fontWeight: FontWeight.w400
        ),
        ValueListenableBuilder(
          valueListenable: _obscurePassword,
          builder:(context, value, child) {
            final obscure = value as bool;
            return Row(
              children: [
                Expanded(
                  child: Fields.formTextField(
                    context: context,
                    textEditingController: _passwordController,
                    obscureText: obscure,
                    label: S.current.labelTypePassword,
                    hint: S.current.messageRepositoryPassword,
                    onSaved: _returnPassword,
                    validator: (
                      password,
                      { error = Strings.messageErrorRepositoryPasswordValidation }
                    ) => formNameValidator(password, error: error),
                    autofocus: true
                  )
                ),
                Fields.actionIcon(
                  Icon(
                    obscure ? Constants.iconVisibilityOn : Constants.iconVisibilityOff,
                    size: Dimensions.sizeIconSmall,
                  ),
                  onPressed: () { _obscurePassword.value = !_obscurePassword.value; }
                )
              ]
            );
          }
        ),
        Fields.dialogActions(
          context,
          buttons: _actions(context)),
      ]
    );
  }

  void _returnPassword(String? password) {
    Navigator.of(context).pop(password);
  }

  List<Widget> _actions(context) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => Navigator.of(context).pop('')),
    PositiveButton(
      text: S.current.actionUnlock,
      onPressed: _validatePassword)
  ];

  void _validatePassword() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}