import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class RenameRepository extends StatelessWidget {
  RenameRepository({
    Key? key,
    required this.context,
    required this.formKey,
    required this.repositoryName
  }) : super(key: key);

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final String repositoryName;

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
          label: S.current.labelRenameRepository,
          hint: S.current.messageRepositoryNewName,
          onSaved: _returnName,
          validator: formNameValidator,
          autofocus: true
        ),
        Fields.dialogActions(
          context,
          buttons: _actions(context)),
      ]
    );
  }

  void _returnName(String? newName) {
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