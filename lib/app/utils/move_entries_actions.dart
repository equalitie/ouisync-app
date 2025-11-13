import 'package:ouisync/ouisync.dart' show AccessMode;
import 'package:ouisync_app/app/utils/utils.dart'
    show AppLogger, CopyEntry, MoveEntry, MultiEntryActions;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show BottomSheetType, RepoCubit, ReposCubit;
import '../models/models.dart' show FileSystemEntry, RepoEntry;
import 'stage.dart';

class MoveEntriesActions with AppLogger {
  MoveEntriesActions({
    required Stage stage,
    required ReposCubit reposCubit,
    required RepoCubit originRepoCubit,
    required BottomSheetType sheetType,
  }) : _stage = stage,
       _reposCubit = reposCubit,
       _originRepoCubit = originRepoCubit,
       _sheetType = sheetType;

  final ReposCubit _reposCubit;
  final RepoCubit _originRepoCubit;
  final BottomSheetType _sheetType;
  final Stage _stage;

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
  ) => switch (_sheetType) {
    BottomSheetType.copy => multiEntryActions.copyEntriesTo(
      destinationRepoCubit,
    ),
    BottomSheetType.delete => multiEntryActions.deleteSelectedEntries(),
    BottomSheetType.download => multiEntryActions.saveEntriesToDevice(),
    BottomSheetType.move => multiEntryActions.moveEntriesTo(
      destinationRepoCubit,
    ),
    BottomSheetType.upload => null,
    BottomSheetType.gone => null,
  };

  Future<void> copyOrMoveSingleEntry({
    required RepoCubit destinationRepoCubit,
    required FileSystemEntry entry,
  }) async {
    final currentFolderPath = destinationRepoCubit.state.currentFolder.path;
    if (currentFolderPath.isEmpty) return;

    final toRepoCubit =
        _originRepoCubit.location.compareTo(destinationRepoCubit.location) != 0
        ? destinationRepoCubit
        : null;

    final action = switch (_sheetType) {
      BottomSheetType.copy => copySingleEntry(
        currentFolderPath,
        entry,
        toRepoCubit,
      ),
      BottomSheetType.move => moveSingleEntry(
        currentFolderPath,
        entry,
        toRepoCubit,
      ),
      _ => null,
    };

    if (action != null) await action;
  }

  Future<void> copySingleEntry(
    String currentFolderPath,
    FileSystemEntry entry,
    RepoCubit? toRepoCubit,
  ) async => CopyEntry(
    originRepoCubit: _originRepoCubit,
    entry: entry,
    destinationPath: currentFolderPath,
    stage: _stage,
  ).copy(currentRepoCubit: toRepoCubit, recursive: true);

  Future<void> moveSingleEntry(
    String currentFolderPath,
    FileSystemEntry entry,
    RepoCubit? toRepoCubit,
  ) async => MoveEntry(
    originRepoCubit: _originRepoCubit,
    entry: entry,
    destinationPath: currentFolderPath,
    stage: _stage,
  ).move(currentRepoCubit: toRepoCubit, recursive: true);

  bool enableAction(
    ({bool destinationOk, String errorMessage}) Function(
      RepoCubit destinationRepoCubit,
      String destinationPath,
    )
    validation,
    RepoEntry? currentRepo,
  ) {
    if (currentRepo == null) return false;

    final currentRepoCubit = currentRepo.cubit;
    if (currentRepoCubit != null) {
      final currentPath = currentRepoCubit.currentFolder;

      final accessMode = currentRepo.accessMode;
      final isCurrentRepoWriteMode = accessMode == AccessMode.write;

      final validationOk = validation(currentRepoCubit, currentPath);

      if (!validationOk.destinationOk) {
        loggy.debug(
          'Error validating multi entry destination: ${validationOk.errorMessage}',
        );
      }

      return isCurrentRepoWriteMode && validationOk.destinationOk;
    }

    return false;
  }

  void cancel() => _reposCubit.bottomSheet.hide();
}
