import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RenameRepository extends StatelessWidget {
  const RenameRepository(
      {Key? key,
      required this.context,
      required this.formKey,
      required this.repositoryName})
      : super(key: key);

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final String repositoryName;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
          Fields.constrainedText('"$repositoryName"',
              flex: 0, fontWeight: FontWeight.w400),
          Fields.formTextField(
              context: context,
              label: S.current.labelRenameRepository,
              hint: S.current.messageRepositoryNewName,
              onSaved: _returnName,
              validator: validateNoEmpty(
                  S.current.messageErrorFormValidatorNameDefault),
              autofocus: true),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  void _returnName(String? newName) {
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
