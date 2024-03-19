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
      required this.navigation,
      required this.data,
      required this.onUpdateBottomSheet,
      required this.onMoveEntry,
      required this.isActionAvailableValidator});

  final BuildContext context;
  final RepoCubit cubit;

  final NavigationCubit navigation;
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
                onTap: () async =>
                    _deleteFolderWithValidation(widget.cubit, widget.data.path),
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.delete),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration),
            const Divider(
                height: 10.0, thickness: 2.0, indent: 20.0, endIndent: 20.0),
            EntryInfoTable(entryInfo: {
              S.current.labelName: widget.data.name,
              S.current.labelLocation: getDirname(widget.data.path),
            })
          ],
        ),
      );

  Future<void> _deleteFolderWithValidation(RepoCubit repo, String path) async {
    final isDirectory = await _isDirectory(repo, path);
    if (!isDirectory) {
      loggy.app('Entry $path is not a directory.');
      return;
    }

    final isEmpty = await _isEmpty(repo, path, context);
    final validationMessage = isEmpty
        ? S.current.messageConfirmFolderDeletion
        : S.current.messageConfirmNotEmptyFolderDeletion;

    final deleteFolder = await Dialogs.deleteFolderAlertDialog(
      widget.context,
      widget.cubit,
      widget.data.path,
      validationMessage,
    );
    if (deleteFolder != true) return;

    final recursive = !isEmpty;
    final deleteFolderOk = await Dialogs.executeFutureWithLoadingDialog(
      context,
      f: repo.deleteFolder(path, recursive),
    );
    if (deleteFolderOk) {
      Navigator.of(context).pop(deleteFolder);

      showSnackBar(S.current.messageFolderDeleted(widget.data.name));
    }
  }

  Future<bool> _isDirectory(RepoCubit repo, String path) async {
    final type = await repo.type(path);
    return type == EntryType.directory;
  }

  Future<bool> _isEmpty(
      RepoCubit repo, String path, BuildContext context) async {
    final Directory directory = await repo.openDirectory(path);
    if (directory.isNotEmpty) {
      loggy.app('Directory $path is not empty');
      return false;
    }

    return true;
  }

  _showMoveEntryBottomSheet(
      String path,
      EntryType type,
      MoveEntryCallback moveEntryCallback,
      BottomSheetCallback bottomSheetControllerCallback) {
    Navigator.of(context).pop();

    final originPath = getDirname(path);
    final bottomSheetMoveEntry = MoveEntryDialog(
      repo: widget.cubit,
      navigation: widget.navigation,
      originPath: originPath,
      path: path,
      type: type,
      onBottomSheetOpen: bottomSheetControllerCallback,
      onMoveEntry: moveEntryCallback,
    );

    widget.onUpdateBottomSheet(bottomSheetMoveEntry, path);
  }

  void _showRenameDialog(FolderItem data) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final oldName = getBasename(data.path);

          return ActionsDialog(
              title: S.current.messageRenameFolder,
              body: RenameEntry(
                  parentContext: context,
                  oldName: oldName,
                  originalExtension: '',
                  isFile: false,
                  hint: S.current.messageFolderName));
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
