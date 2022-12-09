import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryCreation extends StatefulWidget {
  RepositoryCreation(
      {Key? key,
      required this.context,
      required this.cubit,
      required this.formKey})
      : super(key: key);

  final BuildContext context;
  final ReposCubit cubit;
  final GlobalKey<FormState> formKey;

  @override
  State<RepositoryCreation> createState() => _RepositoryCreationState();
}

class _RepositoryCreationState extends State<RepositoryCreation> {
  final TextEditingController _nameController =
      TextEditingController(text: null);

  final TextEditingController _passwordController =
      TextEditingController(text: null);

  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  final ValueNotifier<bool> _obscurePasswordConfirm = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
                reverse: true,
                child: _buildCreateRepositoryWidget(widget.context))
          ]),
    );
  }

  Widget _buildCreateRepositoryWidget(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Dimensions.spacingVerticalDouble,
          Fields.formTextField(
            context: context,
            textEditingController: _nameController,
            label: S.current.labelName,
            hint: S.current.messageRepositoryName,
            onSaved: (_) {},
            validator:
                validateNoEmpty(S.current.messageErrorFormValidatorNameDefault),
            autofocus: true,
          ),
          ValueListenableBuilder(
              valueListenable: _obscurePassword,
              builder: (context, value, child) {
                final obscure = value;
                return Row(children: [
                  Expanded(
                      child: Fields.formTextField(
                          context: context,
                          textEditingController: _passwordController,
                          obscureText: obscure,
                          label: S.current.labelPassword,
                          subffixIcon: Fields.actionIcon(
                              Icon(
                                obscure
                                    ? Constants.iconVisibilityOn
                                    : Constants.iconVisibilityOff,
                                size: Dimensions.sizeIconSmall,
                              ), onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          }),
                          hint: S.current.messageRepositoryPassword,
                          onSaved: (_) {},
                          validator: validateNoEmpty(
                              Strings.messageErrorRepositoryPasswordValidation),
                          autovalidateMode: AutovalidateMode.disabled))
                ]);
              }),
          ValueListenableBuilder(
              valueListenable: _obscurePasswordConfirm,
              builder: (context, value, child) {
                final obscure = value;
                return Row(children: [
                  Expanded(
                    child: Fields.formTextField(
                        context: context,
                        textEditingController: _retypedPasswordController,
                        obscureText: obscure,
                        label: S.current.labelRetypePassword,
                        subffixIcon: Fields.actionIcon(
                            Icon(
                              obscure
                                  ? Constants.iconVisibilityOn
                                  : Constants.iconVisibilityOff,
                              size: Dimensions.sizeIconSmall,
                            ), onPressed: () {
                          _obscurePasswordConfirm.value =
                              !_obscurePasswordConfirm.value;
                        }),
                        hint: S.current.messageRepositoryPassword,
                        onSaved: (_) {},
                        validator: (retypedPassword) =>
                            retypedPasswordValidator(
                              password: _passwordController.text,
                              retypedPassword: retypedPassword,
                            ),
                        autovalidateMode: AutovalidateMode.disabled),
                  )
                ]);
              }),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
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
        PositiveButton(text: S.current.actionCreate, onPressed: _createRepo)
      ];

  void _createRepo() {
    final newRepositoryName = _nameController.text;
    final password = _passwordController.text;

    _onSaved(widget.cubit, newRepositoryName, password);
  }

  void _onSaved(ReposCubit cubit, String name, String password) async {
    if (!(widget.formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.formKey.currentState!.save();

    final info = RepoMetaInfo.fromDirAndName(
        await cubit.settings.defaultRepoLocation(), name);

    final repoEntry = await cubit.createRepository(
      info,
      password: password,
      setCurrent: true,
    );

    if (repoEntry is ErrorRepoEntry) {
      Dialogs.simpleAlertDialog(
        context: widget.context,
        title: S.current.messsageFailedCreateRepository(name),
        message: repoEntry.error,
      );
      return;
    }

    Navigator.of(widget.context).pop(name);
  }
}
