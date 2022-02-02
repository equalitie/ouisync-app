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
    final theme = Theme.of(context);

    return Form(
      key: this.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16.0))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCreateFolderWidget(this.context),
          ],
        ),
      )
    );
  }

  Widget _buildCreateFolderWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.formTextField(
            context: context,
            textEditingController: _nameController,
            label: Strings.labelCreateRepository,
            hint: Strings.messageRepositoryName,
            onSaved: (_) {},
            validator: formNameValidator,
            autofocus: true
          ),
          Fields.formTextField(
            context: context,
            textEditingController: _passwordController,
            obscureText: true,
            label: Strings.labelCreatePassword,
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
      )
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
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(Strings.actionCancel)
    ),
  ];
}