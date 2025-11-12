import 'package:flutter/material.dart';
import 'package:ouisync_app/app/models/models.dart'
    show DirectoryEntry, FileEntry;
import 'package:ouisync_app/app/utils/utils.dart' show Dimensions;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart'
    show EntrySelectionCubit, EntrySelectionActions, RepoCubit;
import '../widgets/widgets.dart' show NegativeButton, PositiveButton;
import 'dialogs.dart';
import 'dirs.dart';
import 'stage.dart';

class MultiEntryActions {
  const MultiEntryActions({
    required Dirs dirs,
    required EntrySelectionCubit entrySelectionCubit,
    required Stage stage,
  }) : _entrySelectionCubit = entrySelectionCubit,
       _dirs = dirs,
       _stage = stage;

  final EntrySelectionCubit _entrySelectionCubit;
  final Dirs _dirs;
  final Stage _stage;

  int get totalSelectedDirs =>
      _entrySelectionCubit.entries.whereType<DirectoryEntry>().length;

  int get totalSelectedFiles =>
      _entrySelectionCubit.entries.whereType<FileEntry>().length;

  Future<bool> saveEntriesToDevice() async {
    String? defaultDirectoryPath = _dirs.download;
    if (defaultDirectoryPath == null) return false;

    final result = await _confirmActionAndExecute(
      EntrySelectionActions.download,
      () => _entrySelectionCubit.saveEntriesToDevice(
        defaultDirectoryPath: defaultDirectoryPath,
        stage: _stage,
      ),
    );

    return result;
  }

  Future<bool> copyEntriesTo(RepoCubit currentRepoCubit) async {
    final currentPath = currentRepoCubit.currentFolder;
    if (currentPath.isEmpty) return false;

    final canCopyOrMove = await _canCopyMoveToDestination(
      destinationRepoCubit: currentRepoCubit,
      entrySelectionCubit: _entrySelectionCubit,
      destinationPath: currentPath,
      errorAlertTitle: 'Copy entries to $currentPath',
    );
    if (!canCopyOrMove) return false;

    final result = await _confirmActionAndExecute(
      EntrySelectionActions.copy,
      () async => await _entrySelectionCubit.copyEntriesTo(
        destinationRepoCubit: currentRepoCubit,
        destinationPath: currentPath,
        stage: _stage,
      ),
    );

    return result;
  }

  Future<bool> moveEntriesTo(RepoCubit currentRepoCubit) async {
    final currentPath = currentRepoCubit.currentFolder;
    if (currentPath.isEmpty) return false;

    final canCopyOrMove = await _canCopyMoveToDestination(
      destinationRepoCubit: currentRepoCubit,
      entrySelectionCubit: _entrySelectionCubit,
      destinationPath: currentPath,
      errorAlertTitle: 'Move entries to $currentPath',
    );
    if (!canCopyOrMove) return false;

    final result = await _confirmActionAndExecute(
      EntrySelectionActions.move,
      () async => await _entrySelectionCubit.moveEntriesTo(
        destinationRepoCubit: currentRepoCubit,
        destinationPath: currentPath,
        stage: _stage,
      ),
    );

    return result;
  }

  Future<bool> deleteSelectedEntries() async {
    final result = await _confirmActionAndExecute(
      EntrySelectionActions.delete,
      () => _entrySelectionCubit.deleteEntries(),
    );

    return result;
  }

  //======================= Helper Functions ===================================

  Future<bool> _confirmActionAndExecute(
    EntrySelectionActions actionType,
    Function action,
  ) async {
    final totalsMessage =
        'Folders: $totalSelectedDirs, Files: $totalSelectedFiles';
    final strings = _getStringsForConfirmationDialog(actionType, totalsMessage);
    final isDangerButton = actionType == EntrySelectionActions.delete;
    final confirmed =
        await _getConfirmation(
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
    String title,
    String message,
    String positiveAction,
    bool isDangerButton,
  ) => AlertDialogWithActions.show(
    _stage,
    title: title,
    body: [Text(message)],
    actions: [
      Row(
        children: [
          NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => _stage.maybePop(false),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
          ),
          PositiveButton(
            text: positiveAction,
            isDangerButton: isDangerButton,
            onPressed: () => _stage.maybePop(true),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
          ),
        ],
      ),
    ],
  );

  Future<bool> _canCopyMoveToDestination({
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

    await SimpleAlertDialog.show(
      _stage,
      title: errorAlertTitle,
      message: result.errorMessage,
    );

    return false;
  }
}
