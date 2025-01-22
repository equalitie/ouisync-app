import 'dart:async';
import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show EntryType;
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../models/models.dart' show DirectoryEntry, FileEntry, FileSystemEntry;
import '../utils/repo_path.dart' as repo_path;
import '../utils/utils.dart'
    show AppLogger, CopyEntry, FileIO, MoveEntry, StringExtension, showSnackBar;
import '../widgets/widgets.dart' show SelectionStatus;
import 'cubits.dart' show CubitActions, RepoCubit;

class EntrySelectionState extends Equatable {
  const EntrySelectionState({
    this.originRepoInfoHash = '',
    this.status = SelectionStatus.off,
    this.selectedEntries = const <FileSystemEntry>[],
    this.updating = false,
  });

  final String originRepoInfoHash;
  final SelectionStatus status;
  final List<FileSystemEntry> selectedEntries;
  final bool updating;

  EntrySelectionState copyWith({
    String? originRepoInfoHash,
    SelectionStatus? selectionState,
    List<FileSystemEntry>? selectedEntries,
    bool? updating,
  }) =>
      EntrySelectionState(
        originRepoInfoHash: originRepoInfoHash ?? this.originRepoInfoHash,
        status: selectionState ?? this.status,
        selectedEntries: selectedEntries ?? this.selectedEntries,
        updating: updating ?? false,
      );

  @override
  List<Object?> get props => [
        originRepoInfoHash,
        status,
        selectedEntries,
        updating,
      ];

  String get selectionOriginPath =>
      selectedEntries.isNotEmpty ? p.dirname(selectedEntries.first.path) : '';

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

  final _entries = <FileSystemEntry>[];
  List<FileSystemEntry> get entries => _entries;

  Future<void> startSelectionForRepo(
    RepoCubit originRepoCubit,
    String currentPath,
  ) async {
    _originRepoCubit = originRepoCubit;
    _originPath = currentPath;

    emitUnlessClosed(state.copyWith(
      originRepoInfoHash: _originRepoInfoHash,
      selectionState: SelectionStatus.on,
      selectedEntries: _entries,
    ));
  }

  Future<void> endSelection() async {
    _originRepoCubit = null;
    _originPath = '';

    _entries.clear();

    emitUnlessClosed(state.copyWith(
      selectionState: SelectionStatus.off,
      selectedEntries: <FileSystemEntry>[],
    ));
  }

  Future<void> selectEntry(String repoInfoHash, FileSystemEntry entry) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
      return;
    }

    if (_entries.contains(entry)) return;

    emitUnlessClosed(state.copyWith(updating: true));

    _entries.add(entry);

    emitUnlessClosed(state.copyWith(
      selectedEntries: _entries,
      updating: false,
    ));
  }

  Future<void> clearEntry(String repoInfoHash, FileSystemEntry entry) async {
    if (_originRepoInfoHash != repoInfoHash) {
      emitUnlessClosed(state);
      return;
    }

    emitUnlessClosed(state.copyWith(updating: true));

    _entries.remove(entry);

    emitUnlessClosed(state.copyWith(
      selectedEntries: _entries,
      updating: false,
    ));
  }

  //============================================================================

  Future<bool> saveEntriesToDevice(
    BuildContext context, {
    required String defaultDirectoryPath,
  }) async {
    final fileIO = FileIO(
      context: context,
      repoCubit: _originRepoCubit!,
    );

    final destinationPaths = await fileIO.getDestinationPath(
      defaultDirectoryPath,
    );
    if (destinationPaths.canceled) {
      final errorMessage = S.current.messageDownloadFileCanceled;
      showSnackBar(errorMessage);

      return false;
    }

    final libraryRootSymbol = repo_path.separator();
    final deviceRootSymbol = p.separator;

    String devicePath = destinationPaths.destinationPath;

    try {
      await for (var entry in Stream.fromIterable(_entries)) {
        final type =
            entry is DirectoryEntry ? EntryType.directory : EntryType.file;

        final path = entry.path.replaceAll(libraryRootSymbol, deviceRootSymbol);
        final destinationPath = p.join(devicePath, path);
        if (type == EntryType.directory) {
          await io.Directory(destinationPath).create(recursive: true);

          continue;
        }

        await fileIO.saveFileToDevice(
          entry as FileEntry,
          null,
          (
            parentPath: destinationPaths.parentPath,
            destinationPath: destinationPath,
          ),
        );
      }
    } on Exception catch (e) {
      loggy.debug('Error saving selected entries to device: ${e.toString()}');
      return false;
    }

    return true;
  }

  Future<bool> copyEntriesTo(
    BuildContext context, {
    required RepoCubit destinationRepoCubit,
    required String destinationPath,
  }) async =>
      _moveOrCopySelectedEntries(
        context,
        action: EntrySelectionActions.copy,
        destinationRepoCubit: destinationRepoCubit,
        destinationPath: destinationPath,
      );

  Future<bool> moveEntriesTo(
    BuildContext context, {
    required RepoCubit destinationRepoCubit,
    required String destinationPath,
  }) async =>
      _moveOrCopySelectedEntries(
        context,
        action: EntrySelectionActions.move,
        destinationRepoCubit: destinationRepoCubit,
        destinationPath: destinationPath,
      );

  Future<bool> _moveOrCopySelectedEntries(
    BuildContext context, {
    required EntrySelectionActions action,
    required RepoCubit destinationRepoCubit,
    required String destinationPath,
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
        context,
        originRepoCubit: _originRepoCubit!,
        toRepoCubit: toRepoCubit,
        destinationPath: destinationPath,
        entry: entry,
      );

      _entries.remove(entry);
    }

    return true;
  }

  Future<void> _copy(
    BuildContext context, {
    required RepoCubit originRepoCubit,
    required RepoCubit? toRepoCubit,
    required String destinationPath,
    required FileSystemEntry entry,
  }) async =>
      CopyEntry(
        context,
        originRepoCubit: originRepoCubit,
        entry: entry,
        destinationPath: destinationPath,
      ).copy(
        currentRepoCubit: toRepoCubit,
        fromPathSegment: entry.path.removePrefix(repo_path.separator()),
        recursive: true,
      );

  Future<void> _move(
    BuildContext context, {
    required RepoCubit originRepoCubit,
    required RepoCubit? toRepoCubit,
    required String destinationPath,
    required FileSystemEntry entry,
  }) async =>
      MoveEntry(
        context,
        originRepoCubit: originRepoCubit,
        entry: entry,
        destinationPath: destinationPath,
      ).move(
        currentRepoCubit: toRepoCubit,
        fromPathSegment: entry.path.removePrefix(repo_path.separator()),
        recursive: true,
      );

  Future<bool> deleteEntries() async {
    try {
      final fileEntriesPath =
          _entries.whereType<FileEntry>().map((e) => e.path);
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

    bool validationOk = true;
    String errorMessage = '';

    final isSameParent = destinationPath == p.dirname(_originPath);
    if (isSameParent) {
      validationOk = false;
      errorMessage = 'The destination is the same as the '
          'source';
    }

    return (destinationOk: validationOk, errorMessage: errorMessage);
  }
}

enum EntrySelectionActions { download, copy, move, delete }
