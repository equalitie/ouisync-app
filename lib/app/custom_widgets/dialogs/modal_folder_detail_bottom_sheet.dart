import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../custom_widgets.dart';

class FolderDetail extends StatefulWidget {
  const FolderDetail({
    required this.context,
    required this.bloc,
    required this.repository,
    required this.name,
    required this.path,
    required this.parent,
    required this.scaffoldKey,
    required this.onBottomSheetOpen,
    required this.onMoveEntry
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final Repository repository;
  final String name;
  final String path;
  final String parent;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final MoveEntryBottomSheetControllerCallback onBottomSheetOpen;
  final MoveEntryCallback onMoveEntry;

  @override
  State<FolderDetail> createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Fields.bottomSheetHandle(context),
          _folderDetails(context),
        ],
      ),
    );
  }

  Widget _folderDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetTitle(widget.name),
          GestureDetector(
            onTap: () => delete(
              widget.context,
              widget.bloc,
              widget.repository,
              widget.parent,
              widget.path
            ),
            child: Fields.iconText(
              icon: Icons.delete_outlined,
              text: 'Delete',
              iconSize: 40.0,
              textSize: 18.0,
              padding: EdgeInsets.only(bottom: 30.0)
            )
          ),
          _buildMoveFolderButton(
            origin: widget.parent,
            path: widget.path,
            type: EntryType.directory,
            moveEntryCallback: widget.onMoveEntry,
            bottomSheetControllerCallback: widget.onBottomSheetOpen
          ),
          Divider(
            height: 50.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          Fields.iconText(
            icon: Icons.info_rounded,
            text: 'Information',
            iconSize: 40.0,
            textSize: 24.0,
            padding: EdgeInsets.only(bottom: 30.0)
          ),
          syncStatus(),
        ]
      )
    );
  }

  void delete(context, bloc, repository, parent, path) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return buildDeleteFolderAlertDialog(
          context,
          bloc,
          repository,
          parent,
          path,
        );
      },
    );

    if (result ?? false) {
      Navigator.of(context).pop(false);
    }
  }

  AlertDialog buildDeleteFolderAlertDialog(context, bloc, repository, parentPath, path) {
    return AlertDialog(
      title: const Text('Delete folder'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              path,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text('Are you sure you want to delete this folder?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('DELETE'),
          onPressed: () => deleteFolderWithContentsValidation(bloc, repository, parentPath, path, context),
        ),
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }

  void deleteFolderWithContentsValidation(bloc, repository, parentPath, path, context) async {
    bool recursive = false;
    final isEmpty = await EntryInfo(repository).isDirectoryEmpty(path: path);
    if (!isEmpty) {
      recursive = await Dialogs
      .alertDialogWithActions(
        context: context,
        title: 'Delete not empty folder',
        body: [Text('This folder is not empty.\n\nDo you still want to delete it, and all its contents?')],
        actions: [
          TextButton(
            child: const Text('DELETE'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(false),
          )
        ]
      ) ?? false;

      if (!recursive) {
        return;
      }
    }
    
    deleteAction(context, bloc, repository, parentPath, path, recursive);
  }

  void deleteAction(context, bloc, repository, parentPath, path, recursive) {
    bloc
    .add(
      DeleteFolder(
        repository: repository,
        parentPath: parentPath,
        path: path,
        recursive: recursive
      )
    );
    
    bloc.add(
      NavigateTo(
        repository: repository,
        type: Navigation.content,
        origin: extractParentFromPath(parentPath),
        destination: parentPath,
        withProgress: true
      )
    );
        
    Navigator.of(context).pop(true);
  }

  GestureDetector _buildMoveFolderButton({
    required String origin,
    required String path,
    required EntryType type,
    required MoveEntryCallback moveEntryCallback,
    required MoveEntryBottomSheetControllerCallback bottomSheetControllerCallback
  }) {
    return GestureDetector(
      onTap: () => _showMoveEntryBottomSheet(
        origin,
        path,
        type,
        moveEntryCallback,
        bottomSheetControllerCallback
      ),
      child: Fields.iconText(
        icon: Icons.drive_file_move_outlined,
        text: 'Move',
        iconSize: 40.0,
        textSize: 18.0,
        padding: EdgeInsets.only(bottom: 30.0)
      ),
    );
  }

  _showMoveEntryBottomSheet(
    String origin,
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    MoveEntryBottomSheetControllerCallback bottomSheetControllerCallback
  ) {
    Navigator.of(context).pop();
    
    final controller = widget.scaffoldKey.currentState?.showBottomSheet(
      (context) => MoveEntryDialog(
        origin: origin,
        path: path,
        type: type,
        onBottomSheetOpen: bottomSheetControllerCallback,
        onMoveEntry: moveEntryCallback
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero
        ),
      ),
    );

    widget.onBottomSheetOpen.call(controller!, path);
  }

  Widget syncStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Fields.idLabel('Sync Status:'),
        Container(
          height: 60.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            border: Border.all(
              color: Colors.green.shade600,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.check
                ),
                Text(
                  'SYNCED',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}