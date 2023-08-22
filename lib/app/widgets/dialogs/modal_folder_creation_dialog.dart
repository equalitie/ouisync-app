import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FolderCreation extends StatelessWidget {
  const FolderCreation(
      {required this.context, required this.cubit, required this.formKey});

  final BuildContext context;
  final RepoCubit cubit;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildCreateFolderWidget(this.context),
    );
  }

  Widget _buildCreateFolderWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Dimensions.spacingVerticalDouble,
          Fields.formTextField(
              context: context,
              label: S.current.labelName,
              hint: S.current.messageFolderName,
              onSaved: (value) => _onSaved(cubit, value),
              validator: validateNoEmptyMaybeRegExpr(
                  emptyError: S.current.messageErrorFormValidatorNameDefault,
                  regExp: Strings.entityNameRegExp,
                  regExpError: S.current.messageErrorCharactersNotAllowed),
              autofocus: true),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  void _onSaved(RepoCubit cubit, newFolderName) async {
    final path = cubit.state.currentFolder.path;
    final newFolderPath = buildDestinationPath(path, newFolderName);

    if (await cubit.exists(newFolderPath)) {
      return;
    }

    await cubit.createFolder(newFolderPath);

    Navigator.of(context).pop(newFolderPath);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(''),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionCreate,
            onPressed: _validateFolderName,
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
      ];

  void _validateFolderName() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}
