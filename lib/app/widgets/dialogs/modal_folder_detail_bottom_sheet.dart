import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

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
  final BottomSheetControllerCallback onBottomSheetOpen;
  final MoveEntryCallback onMoveEntry;

  @override
  State<FolderDetail> createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingBottomSheet,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(context),
          Fields.bottomSheetTitle(Strings.titleFolderDetails),
          Fields.actionText(
            Strings.iconMove,
            onTap: () => _showMoveEntryBottomSheet(
              widget.parent,
              widget.path,
              EntryType.directory,
              widget.onMoveEntry,
              widget.onBottomSheetOpen
            ),
            icon: Icons.drive_file_move_outlined,
          ),
          Fields.actionText(
            Strings.iconDelete,
            onTap: () async => {
              await showDialog<bool>(
                context: widget.context,
                barrierDismissible: false, // user must tap button!
                builder: (context) {
                  return buildDeleteFolderAlertDialog(
                    context,
                    widget.bloc,
                    widget.repository,
                    widget.parent,
                    widget.path,
                  );
                },
              ).then((result) {
                if (result ?? false) {
                  Navigator.of(context).pop(result);
                  Fluttertoast.showToast(msg:
                    Strings
                    .messageFolderDeleted
                    .replaceAll(
                      Strings.replacementName,
                      widget.name
                    )
                  );
                }
              })
            },
            icon: Icons.delete_outlined,
          ),
          Divider(
            height: 10.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          Fields.iconLabel(
            icon: Icons.info_rounded,
            text: Strings.iconInformation,
            iconSize: Dimensions.sizeIconBig,
            textAlign: TextAlign.start,
          ),
          Fields.labeledText(
            label: Strings.labelName,
            labelFontSize: Dimensions.fontAverage,
            text: widget.name,
            textAlign: TextAlign.start,
          ),
          Fields.labeledText(
            label: Strings.labelLocation, 
            labelFontSize: Dimensions.fontAverage,
            text: widget.path
            .replaceAll(widget.name, '')
            .trimRight(),
            textAlign: TextAlign.start,
          ),
        ]
      )
    );
  }

  AlertDialog buildDeleteFolderAlertDialog(context, bloc, repository, parentPath, path) {
    return AlertDialog(
      title: const Text(Strings.titleDeleteFolder),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              path,
              style: TextStyle(
                fontSize: Dimensions.fontAverage,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text(Strings.messageConfirmFolderDeletion),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(Strings.actionDelete),
          onPressed: () => deleteFolderWithContentsValidation(bloc, repository, parentPath, path, context),
        ),
        TextButton(
          child: const Text(Strings.actionCancel),
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
        title: Strings.titleDeleteNotEmptyFolder,
        body: [Text(Strings.messageConfirmNotEmptyFolderDeletion)],
        actions: [
          TextButton(
            child: const Text(Strings.actionDelete),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: const Text(Strings.actionCancel),
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
        origin: extractParentFromPath(parentPath),
        destination: parentPath,
        withProgress: true
      )
    );
        
    Navigator.of(context).pop(true);
  }

  _showMoveEntryBottomSheet(
    String origin,
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    BottomSheetControllerCallback bottomSheetControllerCallback
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
          topLeft: Radius.circular(Dimensions.radiusSmall),
          topRight: Radius.circular(Dimensions.radiusSmall),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero
        ),
      ),
    );

    widget.onBottomSheetOpen.call(controller!, path);
  }
}
