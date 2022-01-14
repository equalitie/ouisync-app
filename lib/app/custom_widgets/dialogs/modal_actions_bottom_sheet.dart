import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../utils/utils.dart';
import '../custom_widgets.dart';

class DirectoryActions extends StatelessWidget {
  const DirectoryActions({
    required this.context,
    required this.bloc,
    required this.repository,
    required this.parent,
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final Repository repository;
  final String parent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Fields.bottomSheetHandle(context),
          _folderDetails(this.context, this.bloc, this.repository, this.parent),
        ],
      ),
    );
  }

  Widget _folderDetails(context, bloc, repository, parent) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetTitle(Strings.titleFolderActions),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAction(
                name: Strings.actionNewFolder,
                icon: Icons.folder_outlined,
                action: () => createFolderDialog(context, bloc, repository, parent)
              ),
              _buildAction(
                name: Strings.actionNewFile,
                icon: Icons.insert_drive_file_outlined,
                action: () async => await addFile(context, bloc, repository, parent)
              )
            ]
          ),
        ]
      )
    );
  }

  Widget _buildAction({name, icon, action}) => Padding(
    padding: EdgeInsets.all(10.0),
    child: GestureDetector(
      onTap: action,
      child: Column(
        children: [
          Icon(
            icon,
            size: 100.0,
          ),
          SizedBox(height: 10.0,),
          Text(
            name,
            style: TextStyle(
              fontSize: 14.0 
            )
          )
        ],
      )
    ),
  ); 

  void createFolderDialog(context, bloc, repository, parent) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: Strings.titleCreateFolder,
          body: FolderCreation(
            context: context,
            bloc: bloc,
            repository: repository,
            path: parent,
            formKey: formKey,
          ),
        );
      }
    ).then((newFolder) => {
      if (newFolder.isNotEmpty) { // If a folder is created, the new folder is returned path; otherwise, empty string.
        Navigator.of(this.context).pop() 
      }
    });
  }

  Future<void> addFile(context, bloc, repository, parent) async {
    final result = await FilePicker
    .platform
    .pickFiles(
      type: FileType.any,
      withReadStream: true
    );

    if(result != null) {
      final newFilePath = parent == '/'
      ? '/${result.files.single.name}'
      : '$parent/${result.files.single.name}';
      
      final exist = await EntryInfo(repository).exist(path: newFilePath);
      if (exist) {
        return;
      }

      final fileByteStream = result.files.single.readStream!;
      bloc.add(
        CreateFile(
          repository: repository,
          parentPath: parent,
          newFilePath: newFilePath,
          fileByteStream: fileByteStream
        )
      );

      Navigator.of(context).pop();
    }
  }
}