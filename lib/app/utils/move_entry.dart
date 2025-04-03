import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;

import '../cubits/cubits.dart' show RepoCubit;
import '../models/models.dart' show FileEntry, FileSystemEntry;
import '../widgets/widgets.dart' show DisambiguationAction;
import 'repo_path.dart' as repo_path;
import 'utils.dart' show AppLogger, EntryOps, FileReadStream, StringExtension;

class MoveEntry with EntryOps, AppLogger {
  MoveEntry(
    BuildContext context, {
    required RepoCubit originRepoCubit,
    required FileSystemEntry entry,
    required String destinationPath,
  })  : _context = context,
        _originRepoCubit = originRepoCubit,
        _entry = entry,
        _destinationPath = destinationPath;

  final BuildContext _context;
  final RepoCubit _originRepoCubit;
  final FileSystemEntry _entry;
  final String _destinationPath;

  Future<void> move({
    required RepoCubit? currentRepoCubit,
    required bool recursive,
  }) async {
    final path = _entry.path;
    final type = _entry is FileEntry ? EntryType.file : EntryType.directory;

    final fromPathSegment = repo_path
        .basename(
          path,
        )
        .removePrefix(
          repo_path.separator(),
        );
    final newPath = repo_path.join(_destinationPath, fromPathSegment);

    final destinationRepoCubit = (currentRepoCubit ?? _originRepoCubit);

    final exist = await destinationRepoCubit.entryExists(newPath);
    if (!exist) {
      await _pickModeAndMoveEntry(
        currentRepoCubit,
        path,
        newPath,
        type,
        recursive,
      );
      return;
    }

    final disambiguationAction = await pickEntryDisambiguationAction(
      _context,
      newPath,
      type,
    );
    switch (disambiguationAction) {
      case DisambiguationAction.replace:
        await _moveAndReplaceFile(currentRepoCubit, path, newPath);
        break;
      case DisambiguationAction.keep:
        await _renameAndMove(currentRepoCubit, path, newPath, type, recursive);
        break;
      default:
        break;
    }
  }

  Future<void> _moveAndReplaceFile(
    RepoCubit? destinationRepoCubit,
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final file = await _originRepoCubit.openFile(sourcePath);
      final fileLength = await file.getLength();

      await (destinationRepoCubit ?? _originRepoCubit).replaceFile(
        filePath: destinationPath,
        length: fileLength,
        fileByteStream: file.readStream(),
      );

      await _originRepoCubit.deleteFile(sourcePath);
    } catch (e, st) {
      loggy.debug(e, st);
    }
  }

  Future<void> _renameAndMove(
    RepoCubit? toRepoCubit,
    String srcPath,
    String dstPath,
    EntryType type,
    bool recursive,
  ) async {
    final newPath = await disambiguateEntryName(
      repoCubit: (toRepoCubit ?? _originRepoCubit),
      path: dstPath,
    );

    await _pickModeAndMoveEntry(toRepoCubit, srcPath, newPath, type, recursive);
  }

  Future<void> _pickModeAndMoveEntry(
    RepoCubit? destinationRepoCubit,
    String sourcePath,
    String destinationPath,
    EntryType type,
    bool recursive,
  ) async {
    if (destinationRepoCubit == null) {
      await _originRepoCubit.moveEntry(
        source: sourcePath,
        destination: destinationPath,
      );

      return;
    }

    await _originRepoCubit.moveEntryToRepo(
      destinationRepoCubit: destinationRepoCubit,
      type: type,
      source: sourcePath,
      destination: destinationPath,
      recursive: recursive,
    );
  }
}
