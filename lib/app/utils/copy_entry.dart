import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import 'utils.dart';
import 'repo_path.dart' as repo_path;

class CopyEntry with EntryOps, AppLogger {
  CopyEntry(
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

  Future<void> copy({required RepoCubit? toRepoCubit}) async {
    final dstRepo = (toRepoCubit ?? _repoCubit);
    final dstFolder = dstRepo.state.currentFolder.path;
    final basename = repo_path.basename(srcPath);
    final dstPath = repo_path.join(dstFolder, basename);

    final exist = await dstRepo.exists(dstPath);
    if (!exist) {
      await _pickModeAndCopyEntry(toRepoCubit, dstPath, type);
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
      await _copyAndReplace(toRepoCubit, dstPath, type);
    }

    if (fileAction == FileAction.keep) {
      await _renameAndCopy(toRepoCubit, dstPath, type);
    }
  }

  Future<void> _copyAndReplace(
    RepoCubit? toRepoCubit,
    String dstPath,
    EntryType type,
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
    String dstPath,
    EntryType type,
  ) async {
    final newPath = await disambiguateEntryName(
      repoCubit: (toRepoCubit ?? _repoCubit),
      path: dstPath,
    );

    await _pickModeAndCopyEntry(toRepoCubit, newPath, type);
  }

  Future<void> _pickModeAndCopyEntry(
    RepoCubit? toRepoCubit,
    String dstPath,
    EntryType type,
  ) async =>
      await _repoCubit.copyEntry(
        source: srcPath,
        destination: dstPath,
        type: type,
        destinationRepoCubit: toRepoCubit,
      );
}
