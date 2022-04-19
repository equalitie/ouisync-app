import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../bloc/blocs.dart';
import '../../utils/utils.dart';
import '../../models/repo_state.dart';

class FolderCreation extends StatelessWidget {
  const FolderCreation({
    Key? key,
    required this.context,
    required this.bloc,
    required this.repository,
    required this.path,
    required this.formKey
  }) : super(key: key);

  final BuildContext context;
  final DirectoryBloc bloc;
  final RepoState repository;
  final String path;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this.formKey,
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
          onSaved: (value) => _onSaved(bloc, value),
          validator: formNameValidator,
          autofocus: true
        ),
        Fields.actionsSection(
          context,
          buttons: _actions(context)
        ),
      ]
    );
  }

  void _onSaved(bloc, newFolderName) async {
    final newFolderPath = buildDestinationPath(this.path, newFolderName);

    if (await repository.exists(newFolderPath)) {
      return;
    }

    bloc.add(
      CreateFolder(
        repository: this.repository,
        parentPath: this.path,
        newFolderPath: newFolderPath
      )
    );

    Navigator.of(this.context).pop(newFolderPath);
  }

  List<Widget> _actions(context) => [
    ElevatedButton(
      onPressed: () {
        if (this.formKey.currentState!.validate()) {
            this.formKey.currentState!.save();
          }
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
