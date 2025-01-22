import 'package:flutter/widgets.dart';
import 'package:ouisync/ouisync.dart' show EntryType;
import 'package:ouisync_app/app/utils/utils.dart'
    show CopyEntry, MoveEntry, MultiEntryActions;
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show BottomSheetType, RepoCubit, ReposCubit;
import '../models/models.dart' show FileEntry, FileSystemEntry, RepoLocation;

class MoveEntriesActions {
  MoveEntriesActions(
    BuildContext context, {
    required ReposCubit reposCubit,
    required RepoCubit originRepoCubit,
    required BottomSheetType sheetType,
  })  : _context = context,
        _reposCubit = reposCubit,
        _originRepoCubit = originRepoCubit,
        _sheetType = sheetType;

  final BuildContext _context;
  final ReposCubit _reposCubit;
  final RepoCubit _originRepoCubit;
  final BottomSheetType _sheetType;

  String getActionText(BottomSheetType type) => switch (type) {
        BottomSheetType.copy => S.current.actionCopy,
        BottomSheetType.delete => S.current.actionDelete,
        BottomSheetType.download => S.current.actionDownload,
        BottomSheetType.move => S.current.actionMove,
        BottomSheetType.upload => '',
        BottomSheetType.gone => '',
      };

  Future<bool>? getAction(
    RepoCubit destinationRepoCubit,
    MultiEntryActions multiEntryActions,
  ) =>
      switch (_sheetType) {
        BottomSheetType.copy =>
          multiEntryActions.copyEntriesTo(destinationRepoCubit),
        BottomSheetType.delete => multiEntryActions.deleteSelectedEntries(),
        BottomSheetType.download => multiEntryActions.saveEntriesToDevice(),
        BottomSheetType.move =>
          multiEntryActions.moveEntriesTo(destinationRepoCubit),
        BottomSheetType.upload => null,
        BottomSheetType.gone => null,
      };

  Future<void> copyOrMoveSingleEntry({
    required RepoCubit destinationRepoCubit,
    required FileSystemEntry entry,
  }) async {
    final currentFolderPath = destinationRepoCubit.state.currentFolder.path;
    if (currentFolderPath.isEmpty) return;

    final entryBaseName = p.basename(entry.path);
    final toRepoCubit =
        _originRepoCubit.location.compareTo(destinationRepoCubit.location) != 0
            ? destinationRepoCubit
            : null;

    final action = switch (_sheetType) {
      BottomSheetType.copy => copySingleEntry(
          currentFolderPath,
          entryBaseName,
          entry,
          toRepoCubit,
        ),
      BottomSheetType.move => moveSingleEntry(
          currentFolderPath,
          entryBaseName,
          entry,
          toRepoCubit,
        ),
      _ => null,
    };

    if (action != null) await action;
  }

  Future<void> copySingleEntry(
    String currentFolderPath,
    String entryBaseName,
    FileSystemEntry entry,
    RepoCubit? toRepoCubit,
  ) async =>
      CopyEntry(
        _context,
        originRepoCubit: _originRepoCubit,
        entry: entry,
        destinationPath: currentFolderPath,
      ).copy(
        currentRepoCubit: toRepoCubit,
        fromPathSegment: entryBaseName,
        recursive: true,
      );

  Future<void> moveSingleEntry(
    String currentFolderPath,
    String entryBaseName,
    FileSystemEntry entry,
    RepoCubit? toRepoCubit,
  ) async =>
      MoveEntry(
        _context,
        originRepoCubit: _originRepoCubit,
        entry: entry,
        destinationPath: currentFolderPath,
      ).move(
        currentRepoCubit: toRepoCubit,
        fromPathSegment: entryBaseName,
        recursive: true,
      );

  bool canMove({
    required FileSystemEntry entry,
    required String destinationPath,
    required RepoLocation? destinationRepoLocation,
    required bool isCurrentRepoWriteMode,
  }) {
    if (_reposCubit.showList) return false;
    if (destinationRepoLocation == null) return false;
    if (!isCurrentRepoWriteMode) return false;

    bool isSameRepo =
        _originRepoCubit.location.compareTo(destinationRepoLocation) == 0
            ? true
            : false;

    final path = entry.path;
    final parent = p.dirname(path);
    final type = entry is FileEntry ? EntryType.file : EntryType.directory;

    final isSamePath = parent.compareTo(destinationPath) == 0 ? true : false;
    if (isSameRepo && isSamePath) return false;

    if (type == EntryType.directory) {
      final isWithinDestination = p.isWithin(path, destinationPath);
      if (isSameRepo && isWithinDestination) return false;
    }

    return true;
  }

  void cancel() => _reposCubit.bottomSheet.hide();
}
