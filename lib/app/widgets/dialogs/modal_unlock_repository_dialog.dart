import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

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

  final TextEditingController _passwordController = new TextEditingController(text: null);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this.formKey,
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
          '\"${this.repositoryName}\"',
          flex: 0,
          fontWeight: FontWeight.w400
        ),
        Fields.formTextField(
          context: context,
          textEditingController: _passwordController,
          obscureText: true,
          label: S.current.labelTypePassword,
          hint: S.current.messageRepositoryPassword,
          onSaved: _returnPassword,
          validator: (
            password,
            { error = Strings.messageErrorRepositoryPasswordValidation }
          ) => formNameValidator(password, error: error),
          autofocus: true
        ),
        Fields.actionsSection(
          context,
          buttons: _actions(context)),
      ]
    );
  }

  void _returnPassword(String? password) {
    Navigator.of(this.context).pop(password);
  }

  List<Widget> _actions(context) => [
    ElevatedButton(
      onPressed: () {
        if (this.formKey.currentState!.validate()) {
          this.formKey.currentState!.save();
        }
      },
      child: Text(S.current.actionUnlock)
    ),
    Dimensions.spacingActionsHorizontal,
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(S.current.actionCancel)
    ),
  ];
}