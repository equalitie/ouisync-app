import 'package:flutter/widgets.dart';
import 'package:ouisync/ouisync.dart' show EntryType;
import 'package:ouisync_app/app/utils/utils.dart'
    show CopyEntry, MoveEntry, MultiEntryActions;
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show BottomSheetType, RepoCubit, ReposCubit;
import '../models/models.dart' show RepoLocation;

class MoveEntriesActions {
  MoveEntriesActions(
    BuildContext context, {
    required ReposCubit reposCubit,
    required RepoCubit originRepoCubit,
    required BottomSheetType type,
  })  : _context = context,
        _reposCubit = reposCubit,
        _originRepoCubit = originRepoCubit,
        _type = type;

  final BuildContext _context;
  final ReposCubit _reposCubit;
  final RepoCubit _originRepoCubit;
  final BottomSheetType _type;

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
      switch (_type) {
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
    required String entryPath,
    required EntryType entryType,
  }) async {
    final currentFolderPath = destinationRepoCubit.state.currentFolder.path;
    if (currentFolderPath.isEmpty) return;

    final entryBaseName = p.basename(entryPath);

    final toRepoCubit =
        _originRepoCubit.location.compareTo(destinationRepoCubit.location) != 0
            ? destinationRepoCubit
            : null;

    final action = switch (_type) {
      BottomSheetType.copy => copySingleEntry(
          currentFolderPath,
          entryBaseName,
          entryPath,
          entryType,
          toRepoCubit,
        ),
      BottomSheetType.move => moveSingleEntry(
          currentFolderPath,
          entryBaseName,
          entryPath,
          entryType,
          toRepoCubit,
        ),
      _ => null,
    };

    if (action != null) await action;
  }

  Future<void> copySingleEntry(
    String currentFolderPath,
    String entryBaseName,
    String entryPath,
    EntryType entryType,
    RepoCubit? toRepoCubit,
  ) async =>
      CopyEntry(
        _context,
        repoCubit: _originRepoCubit,
        srcPath: entryPath,
        dstPath: currentFolderPath,
        type: entryType,
      ).copy(
        toRepoCubit: toRepoCubit,
        fromPathSegment: entryBaseName,
        navigateToDestination: true,
        recursive: true,
      );

  Future<void> moveSingleEntry(
    String currentFolderPath,
    String entryBaseName,
    String entryPath,
    EntryType entryType,
    RepoCubit? toRepoCubit,
  ) async =>
      MoveEntry(
        _context,
        repoCubit: _originRepoCubit,
        srcPath: entryPath,
        dstPath: currentFolderPath,
        type: entryType,
      ).move(
        toRepoCubit: toRepoCubit,
        fromPathSegment: entryBaseName,
        navigateToDestination: true,
        recursive: true,
      );

  bool canMove({
    required String originPath,
    required RepoLocation? destinationRepoLocation,
    required String destinationPath,
    required bool isCurrentRepoWriteMode,
  }) {
    if (_reposCubit.showList) return false;
    if (destinationRepoLocation == null) return false;
    if (!isCurrentRepoWriteMode) return false;

    bool isSameRepo =
        _originRepoCubit.location.compareTo(destinationRepoLocation) == 0
            ? true
            : false;
    final isSamePath =
        originPath.compareTo(destinationPath) == 0 ? true : false;

    if (isSameRepo && isSamePath) return false;

    return true;
  }

  void cancel() => _reposCubit.bottomSheet.hide();
}
