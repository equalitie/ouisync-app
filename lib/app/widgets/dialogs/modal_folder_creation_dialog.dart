import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../utils/utils.dart';

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
  final Repository repository;
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
          label: Strings.labelName,
          hint: Strings.messageCreateFolder,
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
    final newFolderPath = this.path == Strings.rootPath
    ? '/$newFolderName'
    : '${this.path}/$newFolderName';  

    final exist = await EntryInfo(repository).exist(path: newFolderPath);
    if (exist) {
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
      child: Text(Strings.actionCreate)
    ),
    Dimensions.spacingActionsHorizontal,
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(Strings.actionCancel)
    ),
  ];

}