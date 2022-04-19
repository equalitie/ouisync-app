import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../bloc/blocs.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FolderDetail extends StatefulWidget {
  const FolderDetail({
    required this.context,
    required this.bloc,
    required this.repository,
    required this.data,
    required this.scaffoldKey,
    required this.onBottomSheetOpen,
    required this.onMoveEntry
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final Repository repository;
  final FolderItem data;
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
          Fields.bottomSheetTitle(S.current.titleFolderDetails),
          Fields.paddedActionText(
            S.current.iconRename,
            onTap: () => _showNewNameDialog(
              widget.data.path,
            ),
            icon: Icons.edit
          ),
          Fields.paddedActionText(
            S.current.iconMove,
            onTap: () => _showMoveEntryBottomSheet(
              widget.data.path,
              EntryType.directory,
              widget.onMoveEntry,
              widget.onBottomSheetOpen
            ),
            icon: Icons.drive_file_move_outlined,
          ),
          Fields.paddedActionText(
            S.current.iconDelete,
            onTap: () async => {
              await showDialog<bool>(
                context: widget.context,
                barrierDismissible: false, // user must tap button!
                builder: (context) {
                  return buildDeleteFolderAlertDialog(
                    context,
                    widget.bloc,
                    widget.repository,
                    widget.data.path,
                  );
                },
              ).then((result) {
                if (result ?? false) {
                  Navigator.of(context).pop(result);
                  showSnackBar(context, content: Text(S.current.messageFolderDeleted(widget.data.name)));
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
            text: S.current.iconInformation,
            iconSize: Dimensions.sizeIconBig,
            textAlign: TextAlign.start,
          ),
          Fields.labeledText(
            label: S.current.labelName,
            labelFontSize: Dimensions.fontAverage,
            text: widget.data.name,
            textAlign: TextAlign.start,
          ),
          Fields.labeledText(
            label: S.current.labelLocation, 
            labelFontSize: Dimensions.fontAverage,
            text: widget.data.path
            .replaceAll(widget.data.name, '')
            .trimRight(),
            textAlign: TextAlign.start,
          ),
        ]
      )
    );
  }

  AlertDialog buildDeleteFolderAlertDialog(context, bloc, repository, path) {
    final parentPath = getParentSection(path);
    return AlertDialog(
      title: Text(S.current.titleDeleteFolder),
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
            Text(S.current.messageConfirmFolderDeletion),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(S.current.actionDelete),
          onPressed: () => deleteFolderWithContentsValidation(bloc, repository, parentPath, path, context),
        ),
        TextButton(
          child: Text(S.current.actionCancel),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }

  void deleteFolderWithContentsValidation(bloc, repository, parentPath, path, context) async {
    bool recursive = false;
    final isEmpty = await EntryInfo(repository).isDirectoryEmpty(context, path: path);
    if (!isEmpty) {
      recursive = await Dialogs
      .alertDialogWithActions(
        context: context,
        title: S.current.titleDeleteNotEmptyFolder,
        body: [Text(S.current.messageConfirmNotEmptyFolderDeletion)],
        actions: [
          TextButton(
            child: Text(S.current.actionDelete),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text(S.current.actionCancel),
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
        origin: getParentSection(parentPath),
        destination: parentPath,
        withProgress: true
      )
    );
        
    Navigator.of(context).pop(true);
  }

  _showMoveEntryBottomSheet(
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    BottomSheetControllerCallback bottomSheetControllerCallback
  ) {
    Navigator.of(context).pop();
    
    final origin = getParentSection(path);
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

  void _showNewNameDialog(String path) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final name = getBasename(path);

        return ActionsDialog(
          title: S.current.messageRenameFolder,
          body: Rename(
            context: context,
            entryName:  name,
            hint: S.current.messageFolderName,
            formKey: formKey,
          ),
        );
      }
    ).then((newName) {
      if (newName.isNotEmpty) { // The new name provided by the user.
        final parent = getParentSection(path);
        final newEntryPath = buildDestinationPath(parent, newName);

        widget.bloc
        .add(RenameEntry(
          repository: widget.repository,
          path: parent,
          entryPath: path,
          newEntryPath: newEntryPath
        ));

        Navigator.of(context).pop();
      }
    });
  }
}
