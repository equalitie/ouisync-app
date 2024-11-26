import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> addEntry(String repoInfoHash, String path, bool isFolder) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
    }

    _entriesPath.putIfAbsent(path, () => isFolder);

    emitUnlessClosed(state.copyWith(selectedEntriesPath: _entriesPath));
  }

  Future<void> removeEntry(String repoInfoHash, String path) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
    }

    _entriesPath.remove(path);

    emitUnlessClosed(state.copyWith(selectedEntriesPath: selectedEntries));
  }

  Future<void> deleteEntries() async {
    await for (var entry in Stream.fromIterable(_entriesPath.entries)) {
      entry.value
          ? await _originRepoCubit?.deleteFolder(entry.key, true)
          : await _originRepoCubit?.deleteFile(entry.key);
    }
  }
}

enum EntrySelectionActions { download, copy, move, delete }
