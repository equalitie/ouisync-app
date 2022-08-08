import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryCreation extends StatelessWidget {
  RepositoryCreation({
    Key? key,
    required this.context,
    required this.cubit,
    required this.formKey
  }) : super(key: key);

  final BuildContext context;
  final ReposCubit cubit;
  final GlobalKey<FormState> formKey;

  final TextEditingController _nameController = TextEditingController(text: null);
  final TextEditingController _passwordController = TextEditingController(text: null);
  final TextEditingController _retypedPasswordController = TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscurePasswordConfirm = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
          validator: validateNoEmpty(S.current.messageErrorFormValidatorNameDefault),
          autofocus: true,
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
                    validator: validateNoEmpty(Strings.messageErrorRepositoryPasswordValidation),
                    autovalidateMode: AutovalidateMode.disabled
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
                    validator: (retypedPassword) => retypedPasswordValidator(
                      password: _passwordController.text,
                      retypedPassword: retypedPassword,
                    ),
                    autovalidateMode: AutovalidateMode.disabled
                  ),
                ),
                Fields.actionIcon(
                  Icon(
                    obscure ? Constants.iconVisibilityOn : Constants.iconVisibilityOff,
                    size: Dimensions.sizeIconSmall,
                  ),
                  onPressed: () { _obscurePasswordConfirm.value = !_obscurePasswordConfirm.value; }
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

  String? retypedPasswordValidator({
    required String password,
    required String? retypedPassword,
  }) {
    if (retypedPassword == null || password != retypedPassword) {
      return S.current.messageErrorRetypePassword;
    }

    return null;
  }

  List<Widget> _actions(context) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => Navigator.of(context).pop('')),
    PositiveButton(
      text: S.current.actionCreate,
      onPressed: _createRepo)
  ];

  void _createRepo() {
    final newRepositoryName = _nameController.text;
    final password = _passwordController.text;

    _onSaved(cubit, newRepositoryName, password);
  }

  void _onSaved(ReposCubit cubit, String name, String password) {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    formKey.currentState!.save();

    cubit.openRepository(name, password: password, setCurrent: true);
    Navigator.of(context).pop(name);
  }
}
