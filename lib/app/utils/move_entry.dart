import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;

import '../cubits/cubits.dart' show RepoCubit;
import '../widgets/widgets.dart' show FileAction;
import 'repo_path.dart' as repo_path;
import 'utils.dart' show AppLogger, EntryOps;

class MoveEntry with EntryOps, AppLogger {
  MoveEntry(
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

  Future<void> move({
    required RepoCubit? toRepoCubit,
    required String fromPathSegment,
    required bool navigateToDestination,
    required bool recursive,
  }) async {
    final dstRepo = (toRepoCubit ?? _repoCubit);
    final dstFolderPath = repo_path.join(_dstPath, fromPathSegment);

    final exist = await dstRepo.entryExists(dstFolderPath);
    if (!exist) {
      await _pickModeAndMoveEntry(
        toRepoCubit,
        _srcPath,
        dstFolderPath,
        _type,
        navigateToDestination,
        recursive,
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
      await _moveAndReplace(
        toRepoCubit,
        _srcPath,
        dstFolderPath,
        navigateToDestination,
      );
    }

    if (fileAction == FileAction.keep) {
      await _renameAndMove(
        toRepoCubit,
        _srcPath,
        dstFolderPath,
        _type,
        navigateToDestination,
        recursive,
      );
    }
  }

  Future<void> _moveAndReplace(
    RepoCubit? toRepoCubit,
    String srcPath,
    String dstPath,
    bool navigateToDestination, //NEEDED?
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

  Future<void> _renameAndMove(
    RepoCubit? toRepoCubit,
    String srcPath,
    String dstPath,
    EntryType type,
    bool navigateToDestination,
    bool recursive,
  ) async {
    final newPath = await disambiguateEntryName(
      repoCubit: (toRepoCubit ?? _repoCubit),
      path: dstPath,
    );

    await _pickModeAndMoveEntry(
      toRepoCubit,
      srcPath,
      newPath,
      type,
      navigateToDestination,
      recursive,
    );
  }

  Future<void> _pickModeAndMoveEntry(
    RepoCubit? toRepoCubit,
    String srcPath,
    String dstPath,
    EntryType type,
    bool navigateToDestination,
    bool recursive,
  ) async {
    if (toRepoCubit == null) {
      await _repoCubit.moveEntry(
        source: srcPath,
        destination: dstPath,
      );

      return;
    }

    await _repoCubit.moveEntryToRepo(
      destinationRepoCubit: toRepoCubit,
      type: type,
      source: srcPath,
      destination: dstPath,
      recursive: recursive,
      navigateToDestination: navigateToDestination,
    );
  }
}
