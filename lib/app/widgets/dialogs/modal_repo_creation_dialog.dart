import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
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

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscurePasswordConfirm = ValueNotifier<bool>(true);

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
          label: S.current.labelName,
          hint: S.current.messageRepositoryName,
          onSaved: (_) {},
          validator: formNameValidator,
          autofocus: true
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
                    label: S.current.labelPassword,
                    hint: S.current.messageRepositoryPassword,
                    onSaved: (_) {},
                    validator: (
                      password,
                      { error = Strings.messageErrorRepositoryPasswordValidation }
                    ) => formNameValidator(password, error: error),
                    autovalidateMode: AutovalidateMode.disabled
                  )
                ),
                Fields.actionIcon(
                  Icon(
                    obscure ? Constants.iconVisibilityOff : Constants.iconVisibilityOn,
                    size: Dimensions.sizeIconSmall,
                  ),
                  onPressed: () { _obscurePassword.value = !_obscurePassword.value; }
                )
              ]
            );
          }
        ),
        ValueListenableBuilder(
          valueListenable: _obscurePasswordConfirm,
          builder:(context, value, child) {
            final obscure = value as bool;
            return Row(
              children: [
                Expanded(
                  child: Fields.formTextField(
                    context: context,
                    textEditingController: _retypedPasswordController,
                    obscureText: obscure,
                    label: S.current.labelRetypePassword,
                    hint: S.current.messageRepositoryPassword,
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
                ),
                Fields.actionIcon(
                  Icon(
                    obscure ? Constants.iconVisibilityOff : Constants.iconVisibilityOn,
                    size: Dimensions.sizeIconSmall,
                  ),
                  onPressed: () { _obscurePasswordConfirm.value = !_obscurePasswordConfirm.value; }
                )
              ]
            );
          }
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
      child: Text(S.current.actionCreate)
    ),
    Dimensions.spacingActionsHorizontal,
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(S.current.actionCancel)
    ),
  ];
}