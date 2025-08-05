import 'package:flutter/material.dart';
import 'package:ouisync_app/app/models/models.dart'
    show DirectoryEntry, FileEntry;
import 'package:ouisync_app/app/utils/utils.dart' show Dialogs, Dimensions;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart'
    show EntrySelectionCubit, EntrySelectionActions, RepoCubit;
import '../widgets/widgets.dart' show NegativeButton, PositiveButton;
import 'dirs.dart';

class MultiEntryActions {
  const MultiEntryActions(
    BuildContext context, {
    required Dirs dirs,
    required EntrySelectionCubit entrySelectionCubit,
  }) : _context = context,
       _entrySelectionCubit = entrySelectionCubit,
       _dirs = dirs;

  final BuildContext _context;
  final EntrySelectionCubit _entrySelectionCubit;
  final Dirs _dirs;

  int get totalSelectedDirs =>
      _entrySelectionCubit.entries.whereType<DirectoryEntry>().length;

  int get totalSelectedFiles =>
      _entrySelectionCubit.entries.whereType<FileEntry>().length;

  Future<bool> saveEntriesToDevice() async {
    String? defaultDirectoryPath = _dirs.download;
    if (defaultDirectoryPath == null) return false;

    final result = await _confirmActionAndExecute(
      _context,
      EntrySelectionActions.download,
      () async => await _entrySelectionCubit.saveEntriesToDevice(
        _context,
        defaultDirectoryPath: defaultDirectoryPath,
      ),
    );

    return result;
  }

  Future<bool> copyEntriesTo(RepoCubit currentRepoCubit) async {
    final currentPath = currentRepoCubit.currentFolder;
    if (currentPath.isEmpty) return false;

    final canCopyOrMove = await _canCopyMoveToDestination(
      _context,
      destinationRepoCubit: currentRepoCubit,
      entrySelectionCubit: _entrySelectionCubit,
      destinationPath: currentPath,
      errorAlertTitle: 'Copy entries to $currentPath',
    );
    if (!canCopyOrMove) return false;

    final result = await _confirmActionAndExecute(
      _context,
      EntrySelectionActions.copy,
      () async => await _entrySelectionCubit.copyEntriesTo(
        _context,
        destinationRepoCubit: currentRepoCubit,
        destinationPath: currentPath,
      ),
    );

    return result;
  }

  Future<bool> moveEntriesTo(RepoCubit currentRepoCubit) async {
    final currentPath = currentRepoCubit.currentFolder;
    if (currentPath.isEmpty) return false;

    final canCopyOrMove = await _canCopyMoveToDestination(
      _context,
      destinationRepoCubit: currentRepoCubit,
      entrySelectionCubit: _entrySelectionCubit,
      destinationPath: currentPath,
      errorAlertTitle: 'Move entries to $currentPath',
    );
    if (!canCopyOrMove) return false;

    final result = await _confirmActionAndExecute(
      _context,
      EntrySelectionActions.move,
      () async => await _entrySelectionCubit.moveEntriesTo(
        _context,
        destinationRepoCubit: currentRepoCubit,
        destinationPath: currentPath,
      ),
    );

    return result;
  }

  Future<bool> deleteSelectedEntries() async {
    final result = await _confirmActionAndExecute(
      _context,
      EntrySelectionActions.delete,
      () async => await _entrySelectionCubit.deleteEntries(),
    );

    return result;
  }

  //======================= Helper Functions ===================================

  Future<bool> _confirmActionAndExecute(
    BuildContext context,
    EntrySelectionActions actionType,
    Function action,
  ) async {
    final totalsMessage =
        'Folders: $totalSelectedDirs, Files: $totalSelectedFiles';
    final strings = _getStringsForConfirmationDialog(actionType, totalsMessage);
    final isDangerButton = actionType == EntrySelectionActions.delete;
    final confirmed =
        await _getConfirmation(
          context,
          strings.title,
          strings.message,
          strings.positiveText,
          isDangerButton,
        ) ??
        false;

    bool result = false;
    if (confirmed) {
      result = await action.call();
      await _entrySelectionCubit.endSelection();
    }

    return result;
  }

  ({String title, String message, String positiveText})
  _getStringsForConfirmationDialog(
    EntrySelectionActions actionType,
    String totalsMessage,
  ) {
    final String title, message, positiveAction;

    switch (actionType) {
      case EntrySelectionActions.download:
        {
          title = S.current.titleSaveEntriesToDevice;
          message = S.current.messageSaveEntriesToDevice(totalsMessage);
          positiveAction = S.current.actionSave;
        }
      case EntrySelectionActions.copy:
        {
          title = S.current.titleCopyEntries;
          message = S.current.messageCopyEntries(totalsMessage);
          positiveAction = S.current.actionCopy;
        }
      case EntrySelectionActions.move:
        {
          title = S.current.titleMoveEntries;
          message = S.current.messageMoveEntries(totalsMessage);
          positiveAction = S.current.actionMove;
        }
      case EntrySelectionActions.delete:
        {
          title = S.current.titleDeleteEntries;
          message = S.current.messageDeleteEntries(totalsMessage);
          positiveAction = S.current.actionDelete;
        }
    }

    return (title: title, message: message, positiveText: positiveAction);
  }

  Future<bool?> _getConfirmation(
    BuildContext context,
    String title,
    String message,
    String positiveAction,
    bool isDangerButton,
  ) async {
    final result = await Dialogs.alertDialogWithActions(
      context,
      title: title,
      body: [Text(message)],
      actions: [
        Row(
          children: [
            NegativeButton(
              text: S.current.actionCancel,
              onPressed: () async =>
                  await Navigator.of(context).maybePop(false),
              buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
            ),
            PositiveButton(
              text: positiveAction,
              isDangerButton: isDangerButton,
              onPressed: () async => await Navigator.of(context).maybePop(true),
              buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
            ),
          ],
        ),
      ],
    );
    return result;
  }

  Future<bool> _canCopyMoveToDestination(
    BuildContext context, {
    required RepoCubit destinationRepoCubit,
    required EntrySelectionCubit entrySelectionCubit,
    required String destinationPath,
    required String errorAlertTitle,
  }) async {
    final result = entrySelectionCubit.validateDestination(
      destinationRepoCubit,
      destinationPath,
    );
    if (result.destinationOk) return true;
    if (result.errorMessage.isEmpty) return false;

    await Dialogs.simpleAlertDialog(
      context,
      title: errorAlertTitle,
      message: result.errorMessage,
    );

    return false;
  }
}
