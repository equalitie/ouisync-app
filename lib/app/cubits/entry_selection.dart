import 'dart:async';
import 'dart:collection';

import 'package:build_context_provider/build_context_provider.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../models/models.dart' show DirectoryEntry, FileEntry, FileSystemEntry;
import '../utils/utils.dart'
    show AppLogger, CopyEntry, FileIO, MoveEntry, showSnackBar;
import '../widgets/widgets.dart' show SelectionState;
import 'cubits.dart' show CubitActions, RepoCubit, ReposCubit;

class EntrySelectionState extends Equatable {
  const EntrySelectionState({
    this.originRepoInfoHash = '',
    this.selectionState = SelectionState.off,
    this.selectedEntriesPath = const <String,
        ({
      bool isDir,
      bool selected,
      bool? tristate,
    })>{},
    this.updating = false,
  });

  final String originRepoInfoHash;
  final SelectionState selectionState;
  final Map<
      String,
      ({
        bool isDir,
        bool selected,
        bool? tristate,
      })> selectedEntriesPath;
  final bool updating;

  bool isEntrySelected(String repoInfoHash, String path) =>
      selectedEntriesPath.entries.firstWhereOrNull(
          (p) => originRepoInfoHash == repoInfoHash && p.key == path) !=
      null;

  String? get originPath {
    if (selectedEntriesPath.entries.isEmpty) return null;

    final entry = selectedEntriesPath.entries.first;
    final info = entry.value;
    final path = entry.key;
    return (!info.isDir || info.selected) ? p.dirname(path) : path;
  }

  EntrySelectionState copyWith({
    String? originRepoInfoHash,
    SelectionState? selectionState,
    Map<
            String,
            ({
              bool isDir,
              bool selected,
              bool? tristate,
            })>?
        selectedEntriesPath,
    bool? updating,
  }) =>
      EntrySelectionState(
        originRepoInfoHash: originRepoInfoHash ?? this.originRepoInfoHash,
        selectionState: selectionState ?? this.selectionState,
        selectedEntriesPath: selectedEntriesPath ?? this.selectedEntriesPath,
        updating: updating ?? false,
      );

  @override
  List<Object?> get props => [
        originRepoInfoHash,
        selectionState,
        selectedEntriesPath,
        updating,
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
  final SplayTreeMap<String, ({bool isDir, bool selected, bool? tristate})>
      _entriesPath = SplayTreeMap((key1, key2) {
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
  Map<String, ({bool isDir, bool selected, bool? tristate})>
      get selectedEntries => _entriesPath;

  String? get rootDirPath => selectedEntries.entries
      .firstWhereOrNull(
          (e) => e.value.isDir && e.value.selected && e.value.tristate == true)
      ?.key;

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
      selectedEntriesPath: <String,
          ({
        bool isDir,
        bool selected,
        bool? tristate,
      })>{},
    ));
  }

  Future<void> selectEntry(String repoInfoHash, FileSystemEntry entry) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
      return;
    }

    final path = entry.path;
    if (_entriesPath.containsKey(path)) {
      return;
    }

    emitUnlessClosed(state.copyWith(updating: true));

    if (entry is FileEntry) {
      _entriesPath.update(
        path,
        (value) => (isDir: false, selected: true, tristate: true),
        ifAbsent: () => (isDir: false, selected: true, tristate: true),
      );
      await _selectOrUpdateParent(path);
    }

    if (entry is DirectoryEntry) {
      final contents = await _getContents(path);

      if (contents != null && contents.isNotEmpty) {
        await for (var item in Stream.fromIterable(contents)) {
          await selectEntry(repoInfoHash, item);
        }
      }
      _entriesPath.update(
        path,
        (value) => (isDir: true, selected: true, tristate: true),
        ifAbsent: () => (isDir: true, selected: true, tristate: true),
      );

      await _selectOrUpdateParent(path);
    }

    emitUnlessClosed(state.copyWith(
      selectedEntriesPath: _entriesPath,
      updating: false,
    ));
  }

  Future<void> clearEntry(String repoInfoHash, FileSystemEntry entry) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
    }

    emitUnlessClosed(state.copyWith(updating: true));

    final path = entry.path;

    if (entry is FileEntry) {
      _entriesPath.remove(path);
      await _clearOrUpdateParent(path);
    }

    if (entry is DirectoryEntry) {
      final contents = await _getContents(path);
      if (contents == null || contents.isEmpty) {
        _entriesPath.remove(path);
        await _clearOrUpdateParent(path);

        emitUnlessClosed(state.copyWith(
          selectedEntriesPath: _entriesPath,
          updating: false,
        ));
        return;
      }

      await for (var item in Stream.fromIterable(contents)) {
        await clearEntry(repoInfoHash, item);
      }

      _entriesPath.remove(path);
      await _clearOrUpdateParent(path);
    }

    emitUnlessClosed(state.copyWith(
      selectedEntriesPath: _entriesPath,
      updating: false,
    ));
  }

  //============================================================================

  Future<void> saveEntriesToDevice(
    BuildContext context, {
    required String defaultDirectoryPath,
  }) async {
    final fileIO = FileIO(
      context: context,
      repoCubit: _originRepoCubit!,
    );

    final destinationPaths =
        await fileIO.getDestinationPath(defaultDirectoryPath);
    if (destinationPaths.canceled) {
      final errorMessage = S.current.messageDownloadFileCanceled;
      showSnackBar(errorMessage);

      return;
    }

    final separator = p.split(_entriesPath.keys.first).first;
    String rootPath = destinationPaths.destinationPath;

    await for (var entry in Stream.fromIterable(_entriesPath.entries)) {
      if (entry.value.isDir) {
        continue;
      }

      final path = entry.key.replaceAll(separator, p.separator);
      final destinationPath = '$rootPath$path';

      final fileEntry = FileEntry(path: entry.key, size: 0);
      await fileIO.saveFileToDevice(
        fileEntry,
        null,
        (
          parentPath: destinationPaths.parentPath,
          destinationPath: destinationPath,
        ),
      );
    }
  }

  Future<void> copyEntriesTo(
    BuildContext context, {
    required ReposCubit reposCubit,
    required String destinationPath,
  }) async {
    BuildContext? mainContext;
    BuildContextProvider()((c) => mainContext = c);

    final currentRepoInfoHash = reposCubit.currentRepo?.infoHash;
    final cubit = _originRepoInfoHash != currentRepoInfoHash
        ? reposCubit.currentRepo?.cubit
        : null;
    await for (var entry in Stream.fromIterable(_entriesPath.entries)) {
      // final entryType =
      //     entry.value.isDir ? EntryType.directory : EntryType.file;
      if (entry.value.isDir) {
        continue;
      }

      await CopyEntry(
        mainContext!,
        repoCubit: _originRepoCubit!,
        srcPath: entry.key,
        type: EntryType.file,
      ).copy(toRepoCubit: cubit);
    }
  }

  Future<void> movedEntriesTo(
    BuildContext context, {
    required ReposCubit reposCubit,
    String? destinationPath,
  }) async {
    BuildContext? mainContext;
    BuildContextProvider()((c) => mainContext = c);

    final currentRepoInfoHash = reposCubit.currentRepo?.infoHash;
    final cubit = _originRepoInfoHash != currentRepoInfoHash
        ? reposCubit.currentRepo?.cubit
        : null;
    await for (var entry in Stream.fromIterable(_entriesPath.entries)) {
      if (entry.value.isDir) {
        continue;
      }

      await MoveEntry(
        mainContext!,
        repoCubit: _originRepoCubit!,
        srcPath: entry.key,
        type: EntryType.file,
      ).move(toRepoCubit: cubit, originBasename: entry.key);
    }
  }

  Future<void> deleteEntries() async {
    final reversed = _entriesPath.entries.toList().reversed;

    await for (var selectedEntry in Stream.fromIterable(reversed)) {
      final path = selectedEntry.key;

      if (selectedEntry.value.isDir &&
          selectedEntry.value.selected &&
          selectedEntry.value.tristate == true) {
        await _originRepoCubit!.deleteFolder(path, true);
        continue;
      }

      if (!selectedEntry.value.isDir) {
        await _originRepoCubit!.deleteFile(path);
      }
    }
  }

  //===================== Helper functions =====================================

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
            (value) => (isDir: true, selected: false, tristate: true),
            ifAbsent: () => (isDir: true, selected: false, tristate: true),
          )
        : _entriesPath[parentPath] = (
            isDir: true,
            selected: false,
            tristate: null,
          );

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
        : _entriesPath[parentPath] = (
            isDir: true,
            selected: false,
            tristate: null,
          );

    var grandparentPath = p.dirname(parentPath);
    while (grandparentPath != '/') {
      parentTristate == false
          ? await _clearOrUpdateParent(parentPath)
          : _entriesPath[grandparentPath] = (
              isDir: true,
              selected: false,
              tristate: null,
            );

      grandparentPath = p.dirname(grandparentPath);
    }
  }

  Future<List<FileSystemEntry>?> _getContents(String path) async =>
      await _originRepoCubit?.getFolderContents(path);

  ({bool destinationOk, String errorMessage}) validateDestination(
    RepoCubit destinationRepoCubit,
    String destinationPath,
  ) {
    if (destinationRepoCubit.state.infoHash != _originRepoInfoHash) {
      return (destinationOk: true, errorMessage: '');
    }

    bool validationOk = true;
    String errorMessage = '';

    final startingPath = rootDirPath ??
        selectedEntries.entries
            .firstWhereOrNull((e) => e.value.tristate == true)
            ?.key;

    final isSameParent = destinationPath == p.dirname(startingPath!);
    if (isSameParent) {
      validationOk = false;
      errorMessage = 'The destination is the same as the '
          'source';
    }

    final isSamePath = startingPath == destinationPath;
    final isWithin = p.isWithin(startingPath, destinationPath);
    if (isSamePath || isWithin) {
      validationOk = false;
      errorMessage = 'The destination folder is a subfolder of the '
          'source folder';
    }

    return (destinationOk: validationOk, errorMessage: errorMessage);
  }
}

enum EntrySelectionActions { download, copy, move, delete }
