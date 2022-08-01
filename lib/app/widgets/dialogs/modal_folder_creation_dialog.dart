import 'package:flutter/material.dart';
import 'package:ouisync_app/app/widgets/widgets.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/utils.dart';

class FolderCreation extends StatelessWidget {
  const FolderCreation({
    Key? key,
    required this.context,
    required this.cubit,
    required this.repository,
    required this.path,
    required this.formKey
  }) : super(key: key);

  final BuildContext context;
  final DirectoryCubit cubit;
  final RepoState repository;
  final String path;
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
        Fields.formTextField(
          context: context,
          label: S.current.labelName,
          hint: S.current.messageFolderName,
          onSaved: (value) => _onSaved(cubit, value),
          validator: formNameValidator,
          autofocus: true
        ),
        Fields.dialogActions(
          context,
          buttons: _actions(context)
        ),
      ]
    );
  }

  void _onSaved(DirectoryCubit cubit, newFolderName) async {
    final newFolderPath = buildDestinationPath(path, newFolderName);

    if (await repository.exists(newFolderPath)) {
      return;
    }

    await cubit.createFolder(repository, newFolderPath);

    Navigator.of(context).pop(newFolderPath);
  }

  List<Widget> _actions(context) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => Navigator.of(context).pop('')),
    PositiveButton(
      text: S.current.actionCreate,
      onPressed: _validateFolderName)
  ];

  void _validateFolderName() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }

}
