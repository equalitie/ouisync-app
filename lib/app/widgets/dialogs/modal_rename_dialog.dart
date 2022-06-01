import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class Rename extends StatelessWidget {
  Rename({
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
      key: this.formKey,
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
        Fields.constrainedText(
          '\"${this.entryName}\"',
          flex: 0,
          fontWeight: FontWeight.w400
        ),
        Fields.formTextField(
          context: context,
          label: S.current.labelName,
          hint: this.hint,
          onSaved: _returnNewName,
          validator: formNameValidator,
          autofocus: true
        ),
        Fields.dialogActions(
          context,
          buttons: _actions(context)),
      ]
    );
  }

  void _returnNewName(String? newName) {
    // final fileExtension = extractFileTypeFromName(this.entryName);
    final fileExtension = getFileExtension(this.entryName);
    if (fileExtension.isNotEmpty) {
      // newName = '$newName.$fileExtension';
      newName = '$newName$fileExtension';
    }

    Navigator.of(this.context).pop(newName);
  }

  List<Widget> _actions(context) => [
    ElevatedButton(
      onPressed: () {
        if (this.formKey.currentState!.validate()) {
            this.formKey.currentState!.save();
          }
      },
      child: Text(S.current.actionRename)
    ),
    Dimensions.spacingActionsHorizontal,
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(S.current.actionCancel)
    ),
  ];
}