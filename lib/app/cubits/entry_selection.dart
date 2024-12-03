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
    this.selectedEntriesPath = const <String, bool>{},
  });

  final String originRepoInfoHash;
  final SelectionState selectionState;
  final Map<String, bool?> selectedEntriesPath;

  bool isEntrySelected(String repoInfoHash, String path) =>
      selectedEntriesPath.entries.firstWhereOrNull(
          (p) => originRepoInfoHash == repoInfoHash && p.key == path) !=
      null;

  EntrySelectionState copyWith({
    String? originRepoInfoHash,
    SelectionState? selectionState,
    Map<String, bool?>? selectedEntriesPath,
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

  /// key: entry pasth
  /// value: dierctory tristate: null, false, true - file: true, false
  /// Where value == null: at least one child selected; true: all children selected; false: no children selected
  final SplayTreeMap<String, bool?> _entriesPath = SplayTreeMap((key1, key2) {
    final isKey1Dir = p.extension(key1).isEmpty;
    final isKey2Dir = p.extension(key2).isEmpty;

    if (!isKey1Dir && !isKey2Dir) {
      return key2.compareTo(key1);
    }
    if (isKey1Dir && isKey2Dir) {
      return key2.compareTo(key1);
    }
    return isKey1Dir ? -1 : 1;
  });
  Map<String, bool?> get selectedEntries => _entriesPath;

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
      _entriesPath.update(path, (value) => true, ifAbsent: () => true);
      await _selectOrUpdateParent(path);
    }

    if (entry is DirectoryEntry) {
      final contents = await _getContents(path);

      (contents != null && contents.isNotEmpty)
          ? {
              await for (var item in Stream.fromIterable(contents))
                {await selectEntry(repoInfoHash, item)}
            }
          : _entriesPath.update(path, (value) => true, ifAbsent: () => true);

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

  //===================== Helper functions =============================================

  Future<void> _selectOrUpdateParent(String path) async {
    final parentPath = p.dirname(path);
    if (parentPath == '/') return;

    final parentContents = await _getContents(parentPath);
    final unselected = parentContents?.where((e) {
      if (e.path == path) return false;

      if (_entriesPath.containsKey(e.path)) {
        final value = _entriesPath[e.path];
        return value == null ? true : false;
      }

      return true;
    }).toList();

    final parentTristate =
        (unselected == null || unselected.isEmpty) ? true : null;

    parentTristate == true
        ? _entriesPath.update(parentPath, (value) => true, ifAbsent: () => true)
        : _entriesPath[parentPath] = null;

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
        : _entriesPath[parentPath] = null;

    var grandparentPath = p.dirname(parentPath);
    while (grandparentPath != '/') {
      parentTristate == false
          ? await _clearOrUpdateParent(parentPath)
          : _entriesPath[grandparentPath] = null;

      grandparentPath = p.dirname(grandparentPath);
    }
  }

  Future<List<FileSystemEntry>?> _getContents(String path) async =>
      await _originRepoCubit?.getFolderContents(path);
}

enum EntrySelectionActions { download, copy, move, delete }
