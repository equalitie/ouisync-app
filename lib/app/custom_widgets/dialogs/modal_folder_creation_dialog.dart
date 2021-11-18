import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    final theme = Theme.of(context);

    return Form(
      key: this.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16.0))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCreateFolderWidget(this.context),
          ],
        ),
      )
    );
  }

  Widget _buildCreateFolderWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildEntry(
            context,
            'Create a new folder: ',
            'Folder name',
            (value) => _onSaved(bloc, value),
            'Please enter a valid name (unique, no spaces, ...)'),
          buildInfoLabel('Location: ', this.path),
          buildActionsSection(context, _actions(context)),
        ]
      )
    );
  }

  void _onSaved(bloc, newFolderName) async {
    final newFolderPath = this.path == Strings.slash
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
      child: Text('Create')
    ),
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text('Cancel')
    ),
  ];

}