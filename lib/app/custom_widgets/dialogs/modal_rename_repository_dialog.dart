import 'package:flutter/material.dart';

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
          label: Strings.labelRenameRepository,
          hint: Strings.messageRepositoryNewName,
          onSaved: _returnName,
          validator: formNameValidator,
          autofocus: true
        ),
        Fields.actionsSection(
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
      child: Text(Strings.actionRename)
    ),
    Dimensions.spacingActionsHorizontal,
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(Strings.actionCancel)
    ),
  ];
}