import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class Rename extends StatelessWidget {
  const Rename({
    Key? key,
    required this.context,
    required this.entryName,
    required this.hint,
    required this.formKey,
  }) : super(key: key);

  final BuildContext context;
  final String entryName;
  final String hint;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildRenameEntryWidget(this.context),
    );
  }

  Widget _buildRenameEntryWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText('"$entryName"',
              flex: 0, fontWeight: FontWeight.w400),
          Fields.formTextField(
              context: context,
              label: S.current.labelName,
              hint: hint,
              onSaved: _returnNewName,
              validator: validateNoEmpty(
                  S.current.messageErrorFormValidatorNameDefault),
              autofocus: true),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  void _returnNewName(String? newName) {
    final fileExtension = getFileExtension(entryName);
    if (fileExtension.isNotEmpty) {
      newName = '$newName$fileExtension';
    }

    Navigator.of(context).pop(newName);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop('')),
        PositiveButton(
            text: S.current.actionRename, onPressed: _validateNewName)
      ];

  void _validateNewName() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}
