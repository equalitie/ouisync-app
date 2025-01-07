import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart'
    show Dialogs, Dimensions, Native;
import 'package:path_provider/path_provider.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart'
    show EntrySelectionCubit, EntrySelectionActions, RepoCubit;
import '../widgets/widgets.dart' show NegativeButton, PositiveButton;

class MultiEntryActions {
  const MultiEntryActions(
    BuildContext context, {
    required EntrySelectionCubit entrySelectionCubit,
  })  : _context = context,
        _entrySelectionCubit = entrySelectionCubit;

  final BuildContext _context;
  final EntrySelectionCubit _entrySelectionCubit;

  int get totalSelectedDirs => _entrySelectionCubit.selectedEntries.entries
      .where((e) => e.value.isDir && e.value.selected)
      .length;

  int get totalSelectedFiles => _entrySelectionCubit.selectedEntries.entries
      .where((e) => !e.value.isDir)
      .length;

  Future<bool> saveEntriesToDevice() async {
    String? defaultDirectoryPath = await _getDefaultPathForPlatform();
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

  Future<String?> _getDefaultPathForPlatform() async {
    if (io.Platform.isAndroid) {
      return await Native.getDownloadPathForAndroid();
    }

    final defaultDirectory = io.Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getDownloadsDirectory();

    return defaultDirectory?.path;
  }

  Future<bool> _confirmActionAndExecute(
    BuildContext context,
    EntrySelectionActions actionType,
    Function action,
  ) async {
    final totalsMessage =
        'Folders: $totalSelectedDirs, Files: $totalSelectedFiles';
    final strings = _getStringsForConfirmationDialog(actionType, totalsMessage);
    final isDangerButton = actionType == EntrySelectionActions.delete;
    final confirmed = await _getConfirmation(
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

  ({
    String title,
    String message,
    String positiveText,
  }) _getStringsForConfirmationDialog(
    EntrySelectionActions actionType,
    String totalsMessage,
  ) {
    final String title, message, positiveAction;

    switch (actionType) {
      case EntrySelectionActions.download:
        {
          title = 'Save to device';
          message = 'Save selection:\n\n\t\t$totalsMessage';
          positiveAction = S.current.actionSave;
        }
      case EntrySelectionActions.copy:
        {
          title = 'Copy entries';
          message = 'Copy selection here:\n\n\t\t$totalsMessage';
          positiveAction = S.current.actionCopy;
        }
      case EntrySelectionActions.move:
        {
          title = 'Move entries';
          message = 'Move selection here:\n\n\t\t$totalsMessage';
          positiveAction = S.current.actionMove;
        }
      case EntrySelectionActions.delete:
        {
          title = 'Delete entries';
          message = 'Delete selected entries:\n\n\t\t$totalsMessage';
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
