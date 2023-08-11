import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FolderDetail extends StatefulWidget {
  const FolderDetail(
      {required this.context,
      required this.cubit,
      required this.data,
      required this.onUpdateBottomSheet,
      required this.onMoveEntry,
      required this.isActionAvailableValidator});

  final BuildContext context;
  final RepoCubit cubit;
  final FolderItem data;
  final BottomSheetCallback onUpdateBottomSheet;
  final MoveEntryCallback onMoveEntry;
  final bool Function(AccessMode, EntryAction) isActionAvailableValidator;

  @override
  State<FolderDetail> createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> with AppLogger {
  @override
  Widget build(BuildContext context) => Container(
        padding: Dimensions.paddingBottomSheet,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.bottomSheetHandle(context),
            Fields.bottomSheetTitle(S.current.titleFolderDetails,
                style: context.theme.appTextStyle.titleMedium),
            EntryActionItem(
                iconData: Icons.edit,
                title: S.current.iconRename,
                dense: true,
                onTap: () async => _showRenameDialog(widget.data),
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.rename),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration),
            EntryActionItem(
                iconData: Icons.drive_file_move_outlined,
                title: S.current.iconMove,
                dense: true,
                onTap: () async => _showMoveEntryBottomSheet(
                    widget.data.path,
                    EntryType.directory,
                    widget.onMoveEntry,
                    widget.onUpdateBottomSheet),
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.move),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration),
            EntryActionItem(
                iconData: Icons.delete,
                title: S.current.iconDelete,
                isDanger: true,
                dense: true,
                onTap: () async {
                  final repo = widget.cubit;
                  final path = widget.data.path;

                  final recursiveDeletion =
                      await deleteFolderWithContentsValidation(
                          context, repo, path);

                  if (recursiveDeletion == null) {
                    // The item is not a folder or, most likely, the user canceled
                    return;
                  }

                  final deletedFolderName =
                      await Dialogs.deleteFolderAlertDialog(widget.context,
                          widget.cubit, widget.data.path, recursiveDeletion);

                  if (deletedFolderName != null &&
                      deletedFolderName.isNotEmpty) {
                    Navigator.of(context).pop(deletedFolderName);
                    showSnackBar(context,
                        message:
                            S.current.messageFolderDeleted(widget.data.name));
                  }
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.delete),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration),
            const Divider(
                height: 10.0, thickness: 2.0, indent: 20.0, endIndent: 20.0),
            Fields.iconLabel(
                icon: Icons.info_rounded,
                text: S.current.iconInformation,
                iconSize: Dimensions.sizeIconBig,
                textAlign: TextAlign.start,
                style: context.theme.appTextStyle.titleMedium),
            Fields.autosizedLabeledText(
                label: S.current.labelName,
                text: widget.data.name,
                textAlign: TextAlign.start,
                textMaxLines: 2),
            Fields.labeledText(
                label: S.current.labelLocation,
                text: widget.data.path
                    .replaceAll(widget.data.name, '')
                    .trimRight(),
                textAlign: TextAlign.start)
          ],
        ),
      );

  Future<bool?> deleteFolderWithContentsValidation(
      BuildContext context, RepoCubit repo, String path) async {
    bool? recursive = false;

    final type = await repo.type(path);

    if (type != EntryType.directory) {
      loggy.app('Is directory empty: $path is not a directory.');
      return null;
    }

    final Directory directory = await repo.openDirectory(path);

    if (directory.isNotEmpty) {
      String message = S.current.messageErrorPathNotEmpty(path);
      showSnackBar(context, message: message);
    }

    if (directory.isNotEmpty) {
      recursive = await Dialogs.alertDialogWithActions(
          context: context,
          title: S.current.titleDeleteNotEmptyFolder,
          body: [
            Text(S.current.messageConfirmNotEmptyFolderDeletion,
                style: context.theme.appTextStyle.bodyMedium)
          ],
          actions: [
            Fields.dialogActions(context, buttons: [
              NegativeButton(
                  text: S.current.actionCancelCapital,
                  onPressed: () => Navigator.of(context).pop(null),
                  buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
              PositiveButton(
                  text: S.current.actionDeleteCapital,
                  buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
                  onPressed: () => Navigator.of(context).pop(true),
                  isDangerButton: true)
            ])
          ]);
    }

    return recursive;
  }

  _showMoveEntryBottomSheet(
      String path,
      EntryType type,
      MoveEntryCallback moveEntryCallback,
      BottomSheetCallback bottomSheetControllerCallback) {
    Navigator.of(context).pop();

    final origin = getDirname(path);
    final bottomSheetMoveEntry = MoveEntryDialog(widget.cubit,
        origin: origin,
        path: path,
        type: type,
        onBottomSheetOpen: bottomSheetControllerCallback,
        onMoveEntry: moveEntryCallback);

    widget.onUpdateBottomSheet(bottomSheetMoveEntry, path);
  }

  void _showRenameDialog(FolderItem data) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.messageRenameFolder,
            body: Rename(
              context: context,
              entryData: data,
              hint: S.current.messageFolderName,
              formKey: formKey,
            ),
          );
        }).then((newName) {
      if (newName.isNotEmpty) {
        // The new name provided by the user.
        final parent = getDirname(data.path);
        final newEntryPath = buildDestinationPath(parent, newName);

        widget.cubit.moveEntry(source: data.path, destination: newEntryPath);

        Navigator.of(context).pop();
      }
    });
  }
}
