import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../cubits/cubits.dart' show RepoCubit;
import '../widgets/widgets.dart' show FileAction;
import 'utils.dart' show AppLogger, EntryOps;
import 'repo_path.dart' as repo_path;

class MoveEntry with EntryOps, AppLogger {
  MoveEntry(
    BuildContext context, {
    required RepoCubit repoCubit,
    required this.srcPath,
    required this.type,
  })  : _context = context,
        _repoCubit = repoCubit;

  final BuildContext _context;
  final RepoCubit _repoCubit;
  final String srcPath;
  final EntryType type;

  Future<void> move({
    required RepoCubit? toRepoCubit,
    String? originBasename,
    bool navigateToDestination = true,
  }) async {
    final dstRepo = (toRepoCubit ?? _repoCubit);
    final dstFolder = dstRepo.state.currentFolder.path;
    final basename = repo_path.basename(srcPath);
    final dstPath = repo_path.join(dstFolder, basename);

    final exist = await dstRepo.exists(dstPath);
    if (!exist) {
      await _pickModeAndMoveEntry(toRepoCubit, dstPath);
      return;
    }

    final fileAction = await getFileActionType(
      _context,
      basename,
      dstPath,
      type,
    );

    if (fileAction == null) return;

    if (fileAction == FileAction.replace) {
      await _moveAndReplace(toRepoCubit, dstPath);
    }

    if (fileAction == FileAction.keep) {
      await _renameAndMove(toRepoCubit, dstPath);
    }
  }

  Future<void> _moveAndReplace(RepoCubit? toRepoCubit, String dstPath) async {
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

  Future<void> _renameAndMove(RepoCubit? toRepoCubit, String dstPath) async {
    final newPath = await disambiguateEntryName(
      repoCubit: (toRepoCubit ?? _repoCubit),
      path: dstPath,
    );

    await _pickModeAndMoveEntry(toRepoCubit, newPath);
  }

  Future<void> _pickModeAndMoveEntry(
    RepoCubit? toRepoCubit,
    String dstPath,
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
    );
  }
}
