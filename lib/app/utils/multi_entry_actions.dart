import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart'
    show Dialogs, Dimensions, Native;
import 'package:path_provider/path_provider.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart'
    show EntrySelectionCubit, EntrySelectionActions, RepoCubit, ReposCubit;
import '../widgets/widgets.dart' show NegativeButton, PositiveButton;

class MultiEntryActions {
  const MultiEntryActions(
    BuildContext context, {
    required EntrySelectionCubit entrySelectionCubit,
  })  : _context = context,
        _entrySelectionCubit = entrySelectionCubit;

  final BuildContext _context;
  final EntrySelectionCubit _entrySelectionCubit;

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

  Future<bool> copyEntriesTo(
    ReposCubit reposCubit,
    RepoCubit? currentRepo,
  ) async {
    if (currentRepo == null) return false;

    final currentPath = currentRepo.currentFolder;
    if (currentPath.isEmpty) return false;

    final canCopyOrMove = await _canCopyMoveToDestination(
      _context,
      destinationRepoCubit: currentRepo,
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
        reposCubit: reposCubit,
        destinationPath: currentPath,
      ),
    );

    return result;
  }

  Future<bool> moveEntriesTo(
    ReposCubit reposCubit,
    RepoCubit? currentRepo,
  ) async {
    if (currentRepo == null) return false;

    final currentPath = currentRepo.currentFolder;
    if (currentPath.isEmpty) return false;

    final canCopyOrMove = await _canCopyMoveToDestination(
      _context,
      destinationRepoCubit: currentRepo,
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
        reposCubit: reposCubit,
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
    final strings = _getStringsForConfirmationDialog(actionType);
    final confirmed = await _getConfirmation(
          context,
          strings.title,
          strings.message,
          strings.positiveText,
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
  }) _getStringsForConfirmationDialog(EntrySelectionActions actionType) {
    final String title, message, positiveAction;

    switch (actionType) {
      case EntrySelectionActions.download:
        {
          title = 'Save to device';
          message = 'Save selected entries to device';
          positiveAction = S.current.actionSave;
        }
      case EntrySelectionActions.copy:
        {
          title = 'Copy entries';
          message = 'Copy entries here';
          positiveAction = S.current.actionCopy;
        }
      case EntrySelectionActions.move:
        {
          title = 'Move entries';
          message = 'Move entries here';
          positiveAction = S.current.actionMove;
        }
      case EntrySelectionActions.delete:
        {
          title = 'Delete entries';
          message = 'Delete selected entries';
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

    await Dialogs.simpleAlertDialog(
      context,
      title: errorAlertTitle,
      message: result.errorMessage,
    );

    return false;
  }
}
