import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;

import '../cubits/cubits.dart' show RepoCubit;
import '../widgets/widgets.dart' show FileAction;
import 'repo_path.dart' as repo_path;
import 'utils.dart' show AppLogger, EntryOps;

class CopyEntry with EntryOps, AppLogger {
  CopyEntry(
    BuildContext context, {
    required RepoCubit repoCubit,
    required String srcPath,
    required String dstPath,
    required EntryType type,
  })  : _context = context,
        _repoCubit = repoCubit,
        _srcPath = srcPath,
        _dstPath = dstPath,
        _type = type;

  final BuildContext _context;
  final RepoCubit _repoCubit;
  final String _srcPath;
  final String _dstPath;
  final EntryType _type;

  Future<void> copy({
    required RepoCubit? toRepoCubit,
    required String fromPathSegment,
    required bool recursive,
    required bool navigateToDestination,
  }) async {
    final dstRepo = (toRepoCubit ?? _repoCubit);
    final dstFolderPath = repo_path.join(_dstPath, fromPathSegment);

    final exist = await dstRepo.entryExists(dstFolderPath);
    if (!exist) {
      await _pickModeAndCopyEntry(
        toRepoCubit,
        _srcPath,
        dstFolderPath,
        _type,
        recursive,
        navigateToDestination,
      );
      return;
    }

    final fileAction = await getFileActionType(
      _context,
      _srcPath,
      dstFolderPath,
      _type,
    );

    if (fileAction == null) return;

    if (fileAction == FileAction.replace) {
      await _copyAndReplace(
        toRepoCubit,
        _srcPath,
        dstFolderPath,
        navigateToDestination,
      );
    }

    if (fileAction == FileAction.keep) {
      await _renameAndCopy(
        toRepoCubit,
        _srcPath,
        dstFolderPath,
        _type,
        recursive,
        navigateToDestination,
      );
    }
  }

  Future<void> _copyAndReplace(
    RepoCubit? toRepoCubit,
    String srcPath,
    String dstPath,
    bool navigateToDestination, //NEDED?
  ) async {
    try {
      final file = await _repoCubit.openFile(srcPath);
      final fileLength = await file.length;

      await (toRepoCubit ?? _repoCubit).replaceFile(
        filePath: dstPath,
        length: fileLength,
        fileByteStream: file.read(0, fileLength).asStream(),
      );

      await _repoCubit.deleteFile(srcPath);
    } catch (e, st) {
      loggy.debug(e, st);
    }
  }

  Future<void> _renameAndCopy(
    RepoCubit? toRepoCubit,
    String srcPath,
    String dstPath,
    EntryType type,
    bool recursive,
    bool navigateToDestination,
  ) async {
    final newPath = await disambiguateEntryName(
      repoCubit: (toRepoCubit ?? _repoCubit),
      path: dstPath,
    );

    await _pickModeAndCopyEntry(
      toRepoCubit,
      srcPath,
      newPath,
      type,
      recursive,
      navigateToDestination,
    );
  }

  Future<void> _pickModeAndCopyEntry(
    RepoCubit? toRepoCubit,
    String srcPath,
    String dstPath,
    EntryType type,
    bool recursive,
    bool navigateToDestination,
  ) async =>
      _repoCubit.copyEntry(
        source: srcPath,
        destination: dstPath,
        type: type,
        destinationRepoCubit: toRepoCubit,
        recursive: recursive,
        navigateToDestination: navigateToDestination,
      );
}
