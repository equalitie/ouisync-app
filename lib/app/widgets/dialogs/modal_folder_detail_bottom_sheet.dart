import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show BottomSheetType, RepoCubit;
import '../../models/models.dart' show DirectoryEntry;
import '../../utils/utils.dart'
    show
        AppLogger,
        AppThemeExtension,
        Constants,
        Dialogs,
        Dimensions,
        Fields,
        AppLoggy,
        showSnackBar,
        ThemeGetter;
import '../widgets.dart'
    show
        ActionsDialog,
        EntryAction,
        EntryActionItem,
        EntryInfoTable,
        RenameEntry;

class FolderDetail extends StatefulWidget {
  const FolderDetail({
    required this.context,
    required this.repoCubit,
    required this.entry,
    required this.isActionAvailableValidator,
  });

  final BuildContext context;
  final RepoCubit repoCubit;
  final DirectoryEntry entry;
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
            Fields.bottomSheetTitle(
              S.current.titleFolderDetails,
              style: context.theme.appTextStyle.titleMedium,
            ),
            EntryActionItem(
              iconData: Icons.edit_outlined,
              title: S.current.iconRename,
              dense: true,
              onTap: () async => _showRenameDialog(widget.entry),
              enabledValidation: () => widget.isActionAvailableValidator(
                widget.repoCubit.state.accessMode,
                EntryAction.rename,
              ),
              disabledMessage: S.current.messageActionNotAvailable,
              disabledMessageDuration:
                  Constants.notAvailableActionMessageDuration,
            ),
            EntryActionItem(
              iconData: Icons.drive_file_move_outlined,
              title: S.current.iconMove,
              dense: true,
              onTap: () async {
                await Navigator.of(context).maybePop();

                final entryPath = widget.entry.path;
                final entryType = EntryType.directory;

                widget.repoCubit.showMoveEntryBottomSheet(
                  sheetType: BottomSheetType.move,
                  entryPath: entryPath,
                  entryType: entryType,
                );
              },
              enabledValidation: () => widget.isActionAvailableValidator(
                widget.repoCubit.state.accessMode,
                EntryAction.move,
              ),
              disabledMessage: S.current.messageActionNotAvailable,
              disabledMessageDuration:
                  Constants.notAvailableActionMessageDuration,
            ),
            EntryActionItem(
              iconData: Icons.delete_outlined,
              title: S.current.iconDelete,
              isDanger: true,
              dense: true,
              onTap: () => _deleteFolderWithValidation(
                widget.repoCubit,
                widget.entry.path,
              ),
              enabledValidation: () => widget.isActionAvailableValidator(
                widget.repoCubit.state.accessMode,
                EntryAction.delete,
              ),
              disabledMessage: S.current.messageActionNotAvailable,
              disabledMessageDuration:
                  Constants.notAvailableActionMessageDuration,
            ),
            const Divider(
              height: 10.0,
              thickness: 2.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
            EntryInfoTable(
              entryInfo: {
                S.current.labelName: widget.entry.name,
                S.current.labelLocation: p.dirname(widget.entry.path),
              },
            ),
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
      widget.repoCubit,
      widget.entry.path,
      validationMessage,
    );
    if (deleteFolder != true) return;

    final recursive = !isEmpty;
    final deleteFolderOk = await Dialogs.executeFutureWithLoadingDialog(
      null,
      repo.deleteFolder(path, recursive),
    );
    if (deleteFolderOk) {
      Navigator.of(context).pop(deleteFolder);

      showSnackBar(S.current.messageFolderDeleted(widget.entry.name));
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

  void _showRenameDialog(DirectoryEntry entry) async => await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final parent = p.dirname(entry.path);
          final oldName = p.basename(entry.path);

          return ActionsDialog(
            title: S.current.messageRenameFolder,
            body: RenameEntry(
              parentContext: context,
              repoCubit: widget.repoCubit,
              parent: parent,
              oldName: oldName,
              originalExtension: '',
              isFile: false,
              hint: S.current.messageFolderName,
            ),
          );
        },
      ).then(
        (newName) async {
          if (newName.isNotEmpty) {
            // The new name provided by the user.
            final parent = p.dirname(entry.path);
            final newEntryPath = p.join(parent, newName);

            await widget.repoCubit.moveEntry(
              source: entry.path,
              destination: newEntryPath,
            );

            await Navigator.of(context).maybePop();
          }
        },
      );
}
