import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show AccessMode, Directory, EntryType;
import 'package:path/path.dart' as p;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show BottomSheetType, RepoCubit;
import '../../models/models.dart' show DirectoryEntry;
import '../../utils/utils.dart'
    show AppLogger, AppLoggy, AppThemeExtension, Constants, Dialogs, Dimensions, Fields, ThemeGetter, showSnackBar;
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
              onTap: () async {
                final entry = widget.entry;
                final newName = await _getNewFolderName(entry);

                if (newName.isEmpty) return;

                // The new name provided by the user.
                final parent = p.dirname(entry.path);
                final newEntryPath = p.join(parent, newName);

                await widget.repoCubit.moveEntry(
                  source: entry.path,
                  destination: newEntryPath,
                );

                await Navigator.of(context).maybePop();
                showSnackBar(S.current.messageFolderRenamed(newName));
              },
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
              iconData: Icons.copy_outlined,
              title: S.current.iconCopy,
              dense: true,
              onTap: () async {
                await Navigator.of(context).maybePop();

                final entryPath = widget.entry.path;
                final entryType = EntryType.directory;

                widget.repoCubit.showMoveEntryBottomSheet(
                  sheetType: BottomSheetType.copy,
                  entryPath: entryPath,
                  entryType: entryType,
                );
              },
              enabledValidation: () => widget.isActionAvailableValidator(
                widget.repoCubit.state.accessMode,
                EntryAction.copy,
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
                widget.entry,
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

  Future<void> _deleteFolderWithValidation(
    RepoCubit repo,
    DirectoryEntry entry,
  ) async {
    final path = entry.path;
    final isEmpty = await _isEmpty(repo, path, context);
    final deleteFolder = await Dialogs.deleteEntry(
      context,
      repoCubit: repo,
      entry: widget.entry,
      isDirEmpty: isEmpty,
    );
    if (deleteFolder == false) return;

    final recursive = !isEmpty;
    final deleteFolderOk = await Dialogs.executeFutureWithLoadingDialog<bool>(
      null,
      repo.deleteFolder(path, recursive),
    );
    if (deleteFolderOk) {
      Navigator.of(context).pop(deleteFolderOk);

      showSnackBar(S.current.messageFolderDeleted(widget.entry.name));
    }
  }

  Future<bool> _isEmpty(
    RepoCubit repo,
    String path,
    BuildContext context,
  ) async {
    final Directory directory = await repo.openDirectory(path);
    if (directory.isNotEmpty) {
      loggy.debug('Directory $path is not empty');
      return false;
    }

    return true;
  }

  Future<String> _getNewFolderName(DirectoryEntry entry) async {
    final newName = await showDialog<String>(
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
        ) ??
        '';

    return newName;
  }
}
