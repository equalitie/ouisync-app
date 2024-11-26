import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../models/models.dart' show DirectoryEntry, FileEntry, FileSystemEntry;
import '../widgets/widgets.dart' show SelectionState;
import 'cubits.dart' show CubitActions, RepoCubit;

class EntrySelectionState extends Equatable {
  EntrySelectionState({
    this.originRepoInfoHash = '',
    this.selectionState = SelectionState.off,
    this.selectedEntriesPath = const <String, bool>{},
  });

  final String originRepoInfoHash;
  final SelectionState selectionState;
  final Map<String, bool> selectedEntriesPath;

  bool isEntrySelected(String repoInfoHash, String path) =>
      selectedEntriesPath.entries.firstWhereOrNull(
          (p) => originRepoInfoHash == repoInfoHash && p.key == path) !=
      null;

  EntrySelectionState copyWith({
    String? originRepoInfoHash,
    SelectionState? selectionState,
    Map<String, bool>? selectedEntriesPath,
  }) =>
      EntrySelectionState(
        originRepoInfoHash: originRepoInfoHash ?? this.originRepoInfoHash,
        selectionState: selectionState ?? this.selectionState,
        selectedEntriesPath: selectedEntriesPath ?? this.selectedEntriesPath,
      );

  @override
  List<Object?> get props => [
        originRepoInfoHash,
        selectionState,
        selectedEntriesPath,
      ];
}

/// Cubit for selecting multiple files or folders for copy, moving, delete, or download.
class EntrySelectionCubit extends Cubit<EntrySelectionState> with CubitActions {
  EntrySelectionCubit() : super(EntrySelectionState());

  RepoCubit? _originRepoCubit;
  String get _originRepoInfoHash => _originRepoCubit?.state.infoHash ?? '';

  /// key: entry pasth
  /// value: is entry a folder
  final Map<String, bool> _entriesPath = <String, bool>{};
  Map<String, bool> get selectedEntries => _entriesPath;

  Future<void> startSelectionForRepo(RepoCubit originRepoCubit) async {
    _originRepoCubit = originRepoCubit;

    emitUnlessClosed(state.copyWith(
      originRepoInfoHash: _originRepoInfoHash,
      selectionState: SelectionState.on,
      selectedEntriesPath: _entriesPath,
    ));
  }

  Future<void> endSelection() async {
    _originRepoCubit = null;
    _entriesPath.clear();

    emitUnlessClosed(state.copyWith(
      selectionState: SelectionState.off,
      selectedEntriesPath: <String, bool>{},
    ));
  }

  Future<void> selectEntry(String repoInfoHash, FileSystemEntry entry) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
      return;
    }

    final path = entry.path;
    if (_entriesPath.containsKey(path)) return;

    if (entry is FileEntry) {
      final parentPath = p.dirname(path);
      if (parentPath != '/') {
        _entriesPath.putIfAbsent(parentPath, () => true);
      }
      _entriesPath.putIfAbsent(path, () => false);

      emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
      return;
    }

    if (entry is DirectoryEntry) {
      _entriesPath.putIfAbsent(path, () => true);

      final contents = await _getContents(path);
      if (contents == null || contents.isEmpty) {
        emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
        return;
      }

      await for (var item in Stream.fromIterable(contents)) {
        await selectEntry(repoInfoHash, item);
      }

      emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
    }
  }

  Future<void> clearEntry(String repoInfoHash, FileSystemEntry entry) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
    }

    final path = entry.path;

    if (entry is FileEntry) {
      await _removeParentIfLast(path);
      _entriesPath.remove(path);

      emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
      return;
    }

    if (entry is DirectoryEntry) {
      final contents = await _getContents(path);
      if (contents == null || contents.isEmpty) {
        _entriesPath.remove(path);

        emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
        return;
      }

      await for (var item in Stream.fromIterable(contents)) {
        await clearEntry(repoInfoHash, item);
      }

      await _removeParentIfLast(path);
      _entriesPath.remove(path);

      emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
    }
  }

  Future<void> _removeParentIfLast(String path) async {
    final parentPath = p.dirname(path);

    final parentContents = await _getContents(parentPath);
    final selected = parentContents
        ?.where((e) => e.path != path && _entriesPath.containsKey(e.path))
        .toList();

    if (selected == null || selected.isEmpty) {
      _entriesPath.remove(parentPath);
    }
  }

  Future<void> deleteEntries() async {
    await for (var entry in Stream.fromIterable(_entriesPath.entries)) {
      entry.value
          ? await _originRepoCubit?.deleteFolder(entry.key, true)
          : await _originRepoCubit?.deleteFile(entry.key);
    }
  }

  Future<List<FileSystemEntry>?> _getContents(String path) async =>
      await _originRepoCubit?.getFolderContents(path);
}

enum EntrySelectionActions { download, copy, move, delete }
