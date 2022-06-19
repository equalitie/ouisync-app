import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../bloc/blocs.dart';
import '../../utils/utils.dart';
import '../../models/folder_state.dart';
import '../widgets.dart';

class DirectoryActions extends StatelessWidget {
  const DirectoryActions({
    required this.context,
    required this.bloc,
    required this.parent,
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final FolderState parent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Fields.bottomSheetHandle(context),
        Fields.bottomSheetTitle(S.current.titleFolderActions),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAction(
              name: S.current.actionNewFolder,
              icon: Icons.folder_outlined,
              action: () => createFolderDialog(context, bloc, parent)
            ),
            _buildAction(
              name: S.current.actionNewFile,
              icon: Icons.insert_drive_file_outlined,
              action: () async => await addFile(context, bloc, parent)
            )
          ]
        ),
      ]
    );
  }

  Widget _buildAction({name, icon, action}) => Padding(
    padding: Dimensions.paddingBottomSheetActions,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: action,
      child: Column(
        children: [
          Icon(
            icon,
            size: Dimensions.sizeIconExtraBig,
          ),
          Dimensions.spacingVertical,
          Text(
            name,
            style: TextStyle(
              fontSize: Dimensions.fontAverage
            )
          )
        ],
      )
    ),
  ); 

  void createFolderDialog(context, bloc, FolderState parent) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleCreateFolder,
          body: FolderCreation(
            context: context,
            bloc: bloc,
            repository: parent.repo,
            path: parent.path,
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

  Future<void> addFile(context, bloc, FolderState parent) async {
    final result = await FilePicker
    .platform
    .pickFiles(
      type: FileType.any,
      withReadStream: true
    );

    if(result != null) {
      final file = result.files.single;
      final newFilePath = buildDestinationPath(parent.path, file.name);
      
      final repo = parent.repo;
      final exist = await repo.exists(newFilePath);

      if (exist) {
        final type = await repo.type(newFilePath);
        final typeNameForMessage = _getTypeNameForMessage(type);
        showSnackBar(context, content: Text(S.current.messageEntryAlreadyExist(typeNameForMessage)));
        return;
      }

      bloc.add(
        SaveFile(
          repository: parent.repo,
          newFilePath: newFilePath,
          fileName: file.name,
          length: file.size,
          fileByteStream: file.readStream!
        )
      );

      Navigator.of(context).pop();
    }
  }

  String _getTypeNameForMessage(EntryType? type) {
    if (type == null) {
      return S.current.messageEntryTypeDefault;
    }

    return type == EntryType.directory
      ? S.current.messageEntryTypeFolder
      : S.current.messageEntryTypeFile;
  }
}
