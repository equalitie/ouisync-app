import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FolderDetail extends StatefulWidget {
  const FolderDetail({
    required this.context,
    required this.cubit,
    required this.data,
    required this.scaffoldKey,
    required this.onBottomSheetOpen,
    required this.onMoveEntry,
    required this.isActionAvailableValidator,
    Key? key
  }) : super(key: key);

  final BuildContext context;
  final RepoCubit cubit;
  final FolderItem data;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BottomSheetControllerCallback onBottomSheetOpen;
  final MoveEntryCallback onMoveEntry;
  final bool Function(AccessMode, EntryAction) isActionAvailableValidator;

  @override
  State<FolderDetail> createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> with OuiSyncAppLogger {
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
                    widget.cubit,
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
          const Divider(
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

  AlertDialog buildDeleteFolderAlertDialog(BuildContext context, RepoCubit cubit, String path) {
    return AlertDialog(
      title: Text(S.current.titleDeleteFolder),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              path,
              style: const TextStyle(
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
          child: Text(S.current.actionDeleteCapital),
          onPressed: () => deleteFolderWithContentsValidation(cubit, path, context),
        ),
        TextButton(
          child: Text(S.current.actionCancelCapital),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }

  void deleteFolderWithContentsValidation(RepoCubit repo, String path, BuildContext context) async {
    bool recursive = false;

    final type = await repo.type(path);

    if (type != EntryType.directory) {
      loggy.app('Is directory empty: $path is not a directory.');
      return;
    }

    final Directory directory = await repo.openDirectory(path);

    if (directory.isNotEmpty) {
      String message = S.current.messageErrorPathNotEmpty(path);
      showSnackBar(context, content: Text(message));
    }

    if (directory.isNotEmpty) {
      recursive = await Dialogs.alertDialogWithActions(
        context: context,
        title: S.current.titleDeleteNotEmptyFolder,
        body: [Text(S.current.messageConfirmNotEmptyFolderDeletion)],
        actions: [
          TextButton(
            child: Text(S.current.actionDeleteCapital),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text(S.current.actionCancelCapital),
            onPressed: () => Navigator.of(context).pop(false),
          )
        ]
      ) ?? false;

      if (!recursive) {
        return;
      }
    }

    deleteAction(context, repo, path, recursive);
  }

  void deleteAction(BuildContext context, RepoCubit repo, String path, bool recursive) {
    repo.deleteFolder(path, recursive);
    Navigator.of(context).pop(true);
  }

  _showMoveEntryBottomSheet(
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    BottomSheetControllerCallback bottomSheetControllerCallback
  ) {
    Navigator.of(context).pop();

    final origin = getDirname(path);
    final controller = widget.scaffoldKey.currentState?.showBottomSheet(
      (context) => MoveEntryDialog(
        widget.cubit,
        origin: origin,
        path: path,
        type: type,
        onBottomSheetOpen: bottomSheetControllerCallback,
        onMoveEntry: moveEntryCallback
      ),
      enableDrag: false,
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
        final parent = getDirname(path);
        final newEntryPath = buildDestinationPath(parent, newName);

        widget.cubit.moveEntry(source: path, destination: newEntryPath);

        Navigator.of(context).pop();
      }
    });
  }
}
