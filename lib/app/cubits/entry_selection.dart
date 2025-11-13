import 'dart:async';
import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show EntryType;
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../models/models.dart' show DirectoryEntry, FileEntry, FileSystemEntry;
import '../utils/stage.dart';
import '../utils/repo_path.dart' as repo_path;
import '../utils/utils.dart' show AppLogger, CopyEntry, FileIO, MoveEntry;
import '../widgets/widgets.dart' show SelectionStatus;
import 'cubits.dart' show CubitActions, RepoCubit;

class EntrySelectionState extends Equatable {
  const EntrySelectionState({
    this.originRepoInfoHash = '',
    this.status = SelectionStatus.off,
    this.selectedEntries = const <FileSystemEntry>[],
    this.singleEntry = const DirectoryEntry(path: ''),
    this.updating = false,
  });

  final String originRepoInfoHash;
  final SelectionStatus status;
  final List<FileSystemEntry> selectedEntries;
  final FileSystemEntry singleEntry;
  final bool updating;

  EntrySelectionState copyWith({
    String? originRepoInfoHash,
    SelectionStatus? selectionStatus,
    List<FileSystemEntry>? selectedEntries,
    FileSystemEntry? singleEntry,
    bool? updating,
  }) => EntrySelectionState(
    originRepoInfoHash: originRepoInfoHash ?? this.originRepoInfoHash,
    status: selectionStatus ?? status,
    selectedEntries: selectedEntries ?? this.selectedEntries,
    singleEntry: singleEntry ?? this.singleEntry,
    updating: updating ?? false,
  );

  @override
  List<Object?> get props => [
    originRepoInfoHash,
    status,
    selectedEntries,
    singleEntry,
    updating,
  ];

  String get selectionOriginPath => singleEntry.path.isNotEmpty
      ? p.dirname(singleEntry.path)
      : selectedEntries.isNotEmpty
      ? p.dirname(selectedEntries.first.path)
      : '';

  bool isSelectable(String currentRepoInfoHash, String path) {
    if (status == SelectionStatus.off ||
        originRepoInfoHash != currentRepoInfoHash ||
        (selectionOriginPath.isNotEmpty && selectionOriginPath != path)) {
      return false;
    }

    return true;
  }

  bool isEntrySelected(String repoInfoHash, FileSystemEntry entry) {
    if (originRepoInfoHash != repoInfoHash) return false;

    if (singleEntry != DirectoryEntry(path: '')) {
      return singleEntry == entry;
    }

    return selectedEntries.contains(entry);
  }
}

/// Cubit for selecting multiple files or folders for copy, moving, delete, or download.
class EntrySelectionCubit extends Cubit<EntrySelectionState>
    with CubitActions, AppLogger {
  EntrySelectionCubit() : super(const EntrySelectionState());

  RepoCubit? _originRepoCubit;
  String _originPath = '';

  String get _originRepoInfoHash => _originRepoCubit?.state.infoHash ?? '';

  bool _isSingleSelection = false;
  bool get isSingleSelection => _isSingleSelection;

  FileSystemEntry? _singleEntry;
  FileSystemEntry? get singleEntry => _singleEntry;

  final _entries = <FileSystemEntry>[];
  List<FileSystemEntry> get entries => _entries;

  Future<void> startSelectionForRepo(
    RepoCubit originRepoCubit,
    String currentPath, [
    bool isSingleSelection = false,
    FileSystemEntry? singleEntry,
  ]) async {
    _originRepoCubit = originRepoCubit;
    _originPath = currentPath;

    _isSingleSelection = isSingleSelection;
    _singleEntry = singleEntry;

    emitUnlessClosed(
      state.copyWith(
        originRepoInfoHash: _originRepoInfoHash,
        selectionStatus: SelectionStatus.on,
        selectedEntries: _entries,
        singleEntry: _singleEntry,
      ),
    );
  }

  Future<void> endSelection() async {
    _originRepoCubit = null;
    _originPath = '';

    _isSingleSelection = false;
    _singleEntry = null;

    _entries.clear();

    emitUnlessClosed(
      state.copyWith(
        selectionStatus: SelectionStatus.off,
        selectedEntries: <FileSystemEntry>[],
        singleEntry: const DirectoryEntry(path: ''),
      ),
    );
  }

  void selectEntry(String repoInfoHash, FileSystemEntry entry) {
    if (_originRepoInfoHash.isEmpty || _originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
      return;
    }

    if (p.dirname(entry.path) != _originPath) {
      emitUnlessClosed(state);
      return;
    }

    if (_entries.contains(entry)) return;

    emitUnlessClosed(state.copyWith(updating: true));

    _entries.add(entry);

    emitUnlessClosed(
      state.copyWith(selectedEntries: _entries, updating: false),
    );
  }

  void clearEntry(String repoInfoHash, FileSystemEntry entry) {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
      return;
    }

    emitUnlessClosed(state.copyWith(updating: true));

    _entries.remove(entry);

    emitUnlessClosed(
      state.copyWith(selectedEntries: _entries, updating: false),
    );
  }

  //============================================================================

  Future<bool> saveEntriesToDevice({
    required String defaultDirectoryPath,
    required Stage stage,
  }) async {
    final fileIO = FileIO(repoCubit: _originRepoCubit!, stage: stage);

    final destinationPaths = await fileIO.getDestinationPath(
      defaultDirectoryPath,
    );
    if (destinationPaths.canceled) {
      final errorMessage = S.current.messageDownloadFileCanceled;
      stage.showSnackBar(errorMessage);

      return false;
    }

    final libraryRootSymbol = repo_path.separator();
    final deviceRootSymbol = p.separator;

    String devicePath = destinationPaths.destinationPath;

    try {
      await for (var entry in Stream.fromIterable(_entries)) {
        final type = entry is DirectoryEntry
            ? EntryType.directory
            : EntryType.file;

        final path = entry.path.replaceAll(libraryRootSymbol, deviceRootSymbol);
        final destinationPath = p.join(devicePath, path);
        if (type == EntryType.directory) {
          await io.Directory(destinationPath).create(recursive: true);

          continue;
        }

        await fileIO.saveFileToDevice(entry as FileEntry, null, (
          parentPath: destinationPaths.parentPath,
          destinationPath: destinationPath,
        ));
      }
    } on Exception catch (e) {
      loggy.debug('Error saving selected entries to device: ${e.toString()}');
      return false;
    }

    return true;
  }

  Future<bool> copyEntriesTo({
    required RepoCubit destinationRepoCubit,
    required String destinationPath,
    required Stage stage,
  }) async => _moveOrCopySelectedEntries(
    action: EntrySelectionActions.copy,
    destinationRepoCubit: destinationRepoCubit,
    destinationPath: destinationPath,
    stage: stage,
  );

  Future<bool> moveEntriesTo({
    required RepoCubit destinationRepoCubit,
    required String destinationPath,
    required Stage stage,
  }) async => _moveOrCopySelectedEntries(
    action: EntrySelectionActions.move,
    destinationRepoCubit: destinationRepoCubit,
    destinationPath: destinationPath,
    stage: stage,
  );

  Future<bool> _moveOrCopySelectedEntries({
    required EntrySelectionActions action,
    required RepoCubit destinationRepoCubit,
    required String destinationPath,
    required Stage stage,
  }) async {
    final destinationRepoInfoHash = await destinationRepoCubit.infoHash;
    final toRepoCubit = _originRepoInfoHash != destinationRepoInfoHash
        ? destinationRepoCubit
        : null;

    final sortedEntries = [..._entries];
    sortedEntries.sort((a, b) {
      if (a is DirectoryEntry && b is FileEntry) return -1;
      if (a is FileEntry && b is DirectoryEntry) return 1;
      return a.path.compareTo(b.path);
    });

    for (var entry in sortedEntries) {
      await (action == EntrySelectionActions.copy ? _copy : _move)(
        originRepoCubit: _originRepoCubit!,
        toRepoCubit: toRepoCubit,
        destinationPath: destinationPath,
        entry: entry,
        stage: stage,
      );

      _entries.remove(entry);
    }

    return true;
  }

  Future<void> _copy({
    required RepoCubit originRepoCubit,
    required RepoCubit? toRepoCubit,
    required String destinationPath,
    required FileSystemEntry entry,
    required Stage stage,
  }) async => CopyEntry(
    originRepoCubit: originRepoCubit,
    entry: entry,
    destinationPath: destinationPath,
    stage: stage,
  ).copy(currentRepoCubit: toRepoCubit, recursive: true);

  Future<void> _move({
    required RepoCubit originRepoCubit,
    required RepoCubit? toRepoCubit,
    required String destinationPath,
    required FileSystemEntry entry,
    required Stage stage,
  }) async => MoveEntry(
    originRepoCubit: originRepoCubit,
    entry: entry,
    destinationPath: destinationPath,
    stage: stage,
  ).move(currentRepoCubit: toRepoCubit, recursive: true);

  Future<bool> deleteEntries() async {
    try {
      final fileEntriesPath = _entries.whereType<FileEntry>().map(
        (e) => e.path,
      );
      await for (var path in Stream.fromIterable(fileEntriesPath)) {
        await _originRepoCubit!.deleteFile(path);
      }
    } on Exception catch (e) {
      loggy.debug('Error deleting selected files: ${e.toString()}');
      return false;
    }

    try {
      final dirEntriesPath = _entries.whereType<DirectoryEntry>().map(
        (e) => e.path,
      );
      await for (var path in Stream.fromIterable(dirEntriesPath)) {
        await _originRepoCubit!.deleteFolder(path, true);
      }
    } on Exception catch (e) {
      loggy.debug('Error deleting selected dirs: ${e.toString()}');
      return false;
    }

    return true;
  }

  //===================== Helper functions =====================================

  ({bool destinationOk, String errorMessage}) validateDestination(
    RepoCubit destinationRepoCubit,
    String destinationPath,
  ) {
    if (destinationRepoCubit.state.infoHash != _originRepoInfoHash) {
      return (destinationOk: true, errorMessage: '');
    }

    if (_entries.isEmpty) {
      return (destinationOk: false, errorMessage: '');
    }

    if (destinationPath.isEmpty) {
      final errorMessage = 'The destination path is empty';
      return (destinationOk: false, errorMessage: errorMessage);
    }

    if (destinationPath == _originPath) {
      final errorMessage = 'The destination is the same as the source';
      return (destinationOk: false, errorMessage: errorMessage);
    }

    return (destinationOk: true, errorMessage: '');
  }
}

enum EntrySelectionActions { download, copy, move, delete }
