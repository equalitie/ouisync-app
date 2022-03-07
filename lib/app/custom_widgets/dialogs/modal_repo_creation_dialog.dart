import 'package:flutter/material.dart';

import '../../cubit/cubits.dart';
import '../../utils/utils.dart';

class RepositoryCreation extends StatelessWidget {
  RepositoryCreation({
    Key? key,
    required this.context,
    required this.cubit,
    required this.formKey
  }) : super(key: key);

  final BuildContext context;
  final RepositoriesCubit cubit;
  final GlobalKey<FormState> formKey;

  final TextEditingController _nameController = new TextEditingController(text: null);
  final TextEditingController _passwordController = new TextEditingController(text: null);
  final TextEditingController _retypedPasswordController = new TextEditingController(text: null);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            reverse: true,
            child: _buildCreateRepositoryWidget(this.context)
          )
        ]
      ),
    );
  }

  Widget _buildCreateRepositoryWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Fields.formTextField(
          context: context,
          textEditingController: _nameController,
          label: Strings.labelName,
          hint: Strings.messageRepositoryName,
          onSaved: (_) {},
          validator: formNameValidator,
          autofocus: true
        ),
        Fields.formTextField(
          context: context,
          textEditingController: _passwordController,
          obscureText: true,
          label: Strings.labelPassword,
          hint: Strings.messageRepositoryPassword,
          onSaved: (_) {},
          validator: (
            password,
            { error = Strings.messageErrorRepositoryPasswordValidation }
          ) => formNameValidator(password, error: error),
          autovalidateMode: AutovalidateMode.disabled
        ),
        Fields.formTextField(
          context: context,
          textEditingController: _retypedPasswordController,
          obscureText: true,
          label: Strings.labelRetypePassword,
          hint: Strings.messageRepositoryPassword,
          onSaved: (_) {},
          validator: (
            retypedPassword,
            { error = Strings.messageErrorRetypePassword }
          ) => retypedPasswordValidator(
            password: _passwordController.text,
            retypedPassword: retypedPassword!,
            error: error
          ),
          autovalidateMode: AutovalidateMode.disabled
        ),
        Fields.actionsSection(
          context,
          buttons: _actions(context)),
      ]
    );
  }

  String? retypedPasswordValidator({
    required String password,
    required String retypedPassword,
    required String error
  }) {
    if (password != retypedPassword) {
      return error;
    }

    return null;
  }

  void _onSaved(RepositoriesCubit cubit, String name, String password) {
    if (!this.formKey.currentState!.validate()) {
      return;
    }

    this.formKey.currentState!.save();

    cubit.openRepository(name: name, password: password);
    Navigator.of(this.context).pop(name);
  }

  List<Widget> _actions(context) => [
    ElevatedButton(
      onPressed: () {
        final newRepositoryName = _nameController.text;
        final password = _passwordController.text;
        
        _onSaved(cubit, newRepositoryName, password);
      },
      child: Text(Strings.actionCreate)
    ),
    Dimensions.spacingActionsHorizontal,
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(Strings.actionCancel)
    ),
  ];
}