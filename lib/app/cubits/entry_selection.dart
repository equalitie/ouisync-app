import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../models/models.dart' show DirectoryEntry, FileEntry, FileSystemEntry;
import '../utils/utils.dart' show AppLogger;
import '../widgets/widgets.dart' show SelectionState;
import 'cubits.dart' show CubitActions, RepoCubit;

class EntrySelectionState extends Equatable {
  EntrySelectionState({
    this.originRepoInfoHash = '',
    this.selectionState = SelectionState.off,
    this.selectedEntriesPath = const <String, ({bool isDir, bool? tristate})>{},
  });

  final String originRepoInfoHash;
  final SelectionState selectionState;
  final Map<String, ({bool isDir, bool? tristate})> selectedEntriesPath;

  bool isEntrySelected(String repoInfoHash, String path) =>
      selectedEntriesPath.entries.firstWhereOrNull(
          (p) => originRepoInfoHash == repoInfoHash && p.key == path) !=
      null;

  EntrySelectionState copyWith({
    String? originRepoInfoHash,
    SelectionState? selectionState,
    Map<String, ({bool isDir, bool? tristate})>? selectedEntriesPath,
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
class EntrySelectionCubit extends Cubit<EntrySelectionState>
    with CubitActions, AppLogger {
  EntrySelectionCubit() : super(EntrySelectionState());

  RepoCubit? _originRepoCubit;
  String get _originRepoInfoHash => _originRepoCubit?.state.infoHash ?? '';

  /// key: Entry path
  /// value: (#1: isDir, #2: state) (directory tristate: null, _, true; file: true, _)
  /// Where tristate == null: at least one child selected; true: all children selected
  final SplayTreeMap<String, ({bool isDir, bool? tristate})> _entriesPath =
      SplayTreeMap((key1, key2) {
    final isKey1Dir = p.extension(key1).isEmpty;
    final isKey2Dir = p.extension(key2).isEmpty;

    if (!isKey1Dir && !isKey2Dir) {
      return key1.compareTo(key2);
    }
    if (isKey1Dir && isKey2Dir) {
      return key1.compareTo(key2);
    }
    return isKey1Dir ? -1 : 1;
  });
  Map<String, ({bool isDir, bool? tristate})> get selectedEntries =>
      _entriesPath;

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
      selectedEntriesPath: <String, ({bool isDir, bool? tristate})>{},
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
      _entriesPath.update(
        path,
        (value) => (isDir: false, tristate: true),
        ifAbsent: () => (isDir: false, tristate: true),
      );
      await _selectOrUpdateParent(path);
    }

    if (entry is DirectoryEntry) {
      final contents = await _getContents(path);

      (contents != null && contents.isNotEmpty)
          ? {
              await for (var item in Stream.fromIterable(contents))
                {await selectEntry(repoInfoHash, item)}
            }
          : _entriesPath.update(
              path,
              (value) => (isDir: true, tristate: true),
              ifAbsent: () => (isDir: true, tristate: true),
            );

      await _selectOrUpdateParent(path);
    }

    emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
  }

  Future<void> clearEntry(String repoInfoHash, FileSystemEntry entry) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
    }

    final path = entry.path;

    if (entry is FileEntry) {
      _entriesPath.remove(path);
      await _clearOrUpdateParent(path);

      emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
      return;
    }

    if (entry is DirectoryEntry) {
      final contents = await _getContents(path);
      if (contents == null || contents.isEmpty) {
        _entriesPath.remove(path);
        await _clearOrUpdateParent(path);

        emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
        return;
      }

      await for (var item in Stream.fromIterable(contents)) {
        await clearEntry(repoInfoHash, item);
      }

      _entriesPath.remove(path);
      await _clearOrUpdateParent(path);

      emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
    }
  }

  Future<void> deleteEntries() async {
    final reversed = _entriesPath.entries.toList().reversed;

    final results = <String, bool>{};
    await for (var selectedEntry in Stream.fromIterable(reversed)) {
      final path = selectedEntry.key;

      if (selectedEntry.value.isDir && selectedEntry.value.tristate == true) {
        final r = await _originRepoCubit!.deleteFolder(path, true);
        results.putIfAbsent(path, () => r);
        continue;
      }
      final r2 = await _originRepoCubit!.deleteFile(path);
      results.putIfAbsent(path, () => r2);
    }

    loggy.debug(results.entries.map((e) => 'Deletion: ${e.key} (${e.value})'));
  }

  //===================== Helper functions =============================================

  Future<void> _selectOrUpdateParent(String path) async {
    final parentPath = p.dirname(path);
    if (parentPath == '/') return;

    final parentContents = await _getContents(parentPath);
    final unselected = parentContents?.where((e) {
      // if (e.path == path) return false;

      if (_entriesPath.containsKey(e.path)) {
        final value = _entriesPath[e.path];
        return value?.tristate == null ? true : false;
      }

      return true;
    }).toList();

    final parentTristate =
        (unselected == null || unselected.isEmpty) ? true : null;

    parentTristate == true
        ? _entriesPath.update(
            parentPath,
            (value) => (isDir: true, tristate: true),
            ifAbsent: () => (isDir: true, tristate: true),
          )
        : _entriesPath[parentPath] = (isDir: true, tristate: null);

    if (parentPath == '/') return;
    await _selectOrUpdateParent(parentPath);
  }

  Future<void> _clearOrUpdateParent(String path) async {
    final parentPath = p.dirname(path);

    final parentContents = await _getContents(parentPath);
    final selected = parentContents
        ?.where((e) => e.path != path && _entriesPath.containsKey(e.path))
        .toList();

    final parentTristate =
        (selected == null || selected.isEmpty) ? false : null;

    parentTristate == false
        ? _entriesPath.remove(parentPath)
        : _entriesPath[parentPath] = (isDir: true, tristate: null);

    var grandparentPath = p.dirname(parentPath);
    while (grandparentPath != '/') {
      parentTristate == false
          ? await _clearOrUpdateParent(parentPath)
          : _entriesPath[grandparentPath] = (isDir: true, tristate: null);

      grandparentPath = p.dirname(grandparentPath);
    }
  }

  Future<List<FileSystemEntry>?> _getContents(String path) async =>
      await _originRepoCubit?.getFolderContents(path);
}

enum EntrySelectionActions { download, copy, move, delete }
