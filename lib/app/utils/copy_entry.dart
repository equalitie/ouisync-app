import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;

import '../cubits/cubits.dart' show RepoCubit;
import '../models/models.dart' show FileEntry, FileSystemEntry;
import '../widgets/widgets.dart' show DisambiguationAction;
import 'repo_path.dart' as repo_path;
import 'utils.dart' show AppLogger, EntryOps, FileReadStream, StringExtension;

class CopyEntry with EntryOps, AppLogger {
  CopyEntry(
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

  /// Copy an entry to the destination path.
  ///
  /// If [currentRepoCubit] is not null, the cubit is used to copy the entry;
  /// otherwise [originRepoCubit] will be used.
  ///
  /// [fromPathSegment] is the segment of [sourcePath] without the entry's
  /// parent folder, including root (/). This is used to create the new path for
  /// the entry to copy, by joining it with the [destinationPath].
  ///
  /// [recursive] is used if the entry is a folder.
  Future<void> copy({
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
      await _copyEntry(
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
        await _copyAndReplaceFile(currentRepoCubit, path, newPath);
        break;
      case DisambiguationAction.keep:
        await _renameAndCopy(currentRepoCubit, path, newPath, type, recursive);
        break;
      default:
        break;
    }
  }

  /// Replaces the file at [destinationPath] with the file at [sourcePath].
  ///
  /// This action is only available for files. If the entry is a folder, this
  /// option will appear disabled to the user.
  Future<void> _copyAndReplaceFile(
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

  /// Disambiguates the entry name by appending a numeric value to [sourcePath]
  /// and creates [newPath] using the disambiguated name, and the original
  /// [destinationPath].
  Future<void> _renameAndCopy(
    RepoCubit? destinationRepoCubit,
    String sourcePath,
    String destinationPath,
    EntryType type,
    bool recursive,
  ) async {
    final newPath = await disambiguateEntryName(
      repoCubit: (destinationRepoCubit ?? _originRepoCubit),
      path: destinationPath,
    );

    await _copyEntry(
      destinationRepoCubit,
      sourcePath,
      newPath,
      type,
      recursive,
    );
  }

  /// Copies the entry at [sourcePath] to [destinationPath].
  ///
  /// If [destinationRepoCubit] is not null, the entry will be copied using the
  /// [destinationRepoCubit].
  Future<void> _copyEntry(
    RepoCubit? destinationRepoCubit,
    String sourcePath,
    String destinationPath,
    EntryType type,
    bool recursive,
  ) async =>
      _originRepoCubit.copyEntry(
        source: sourcePath,
        destination: destinationPath,
        type: type,
        destinationRepoCubit: destinationRepoCubit,
        recursive: recursive,
      );
}
