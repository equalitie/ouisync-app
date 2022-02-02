import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Form(
      key: this.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 00.0, horizontal: 16.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16.0))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnlockRepositoryWidget(this.context),
          ],
        ),
      )
    );
  }

  Widget _buildUnlockRepositoryWidget(BuildContext context) {
    return Padding(
      padding: Dimensions.paddingDialog,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10.0,),
          Fields.constrainedText(
            '\"${this.repositoryName}\"',
            flex: 0,
            fontWeight: FontWeight.w400
          ),
          Fields.formTextField(
            context: context,
            textEditingController: _passwordController,
            obscureText: true,
            label: Strings.labelTypePassword,
            hint: Strings.messageRepositoryPassword,
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
      )
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
      child: Text(Strings.actionUnlock)
    ),
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(Strings.actionCancel)
    ),
  ];
}