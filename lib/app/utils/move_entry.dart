import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart' as p;

import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import 'utils.dart';

class MoveEntry with EntryOps, AppLogger {
  MoveEntry(
    BuildContext context, {
    required RepoCubit repoCubit,
    required this.path,
    required this.type,
  })  : _context = context,
        _repoCubit = repoCubit;

  final BuildContext _context;
  final RepoCubit _repoCubit;
  final String path;
  final EntryType type;

  Future<void> move({required RepoCubit? toRepoCubit}) async {
    final currentFolder = (toRepoCubit ?? _repoCubit).state.currentFolder.path;
    final basename = p.basename(path);
    final toPath = p.join(currentFolder, basename);

    final exist = await (toRepoCubit ?? _repoCubit).exists(toPath);
    if (!exist) {
      await _pickModeAndMoveEntry(toRepoCubit, toPath);
      return;
    }

    final fileAction = await getFileActionType(
      _context,
      basename,
      toPath,
      type,
    );

    if (fileAction == null) return;

    if (fileAction == FileAction.replace) {
      await _moveAndReplace(toRepoCubit, toPath);
    }

    if (fileAction == FileAction.keep) {
      await _renameAndMove(toRepoCubit, toPath);
    }
  }

  Future<void> _moveAndReplace(RepoCubit? toRepoCubit, String toPath) async {
    try {
      final file = await _repoCubit.openFile(path);
      final fileLength = await file.length;

      await (toRepoCubit ?? _repoCubit).replaceFile(
        filePath: toPath,
        length: fileLength,
        fileByteStream: file.read(0, fileLength).asStream(),
      );

      await _repoCubit.deleteFile(path);
    } catch (e, st) {
      loggy.debug(e, st);
    }
  }

  Future<void> _renameAndMove(RepoCubit? toRepoCubit, String toPath) async {
    final newPath = await disambiguateEntryName(
      repoCubit: (toRepoCubit ?? _repoCubit),
      path: toPath,
    );

    await _pickModeAndMoveEntry(toRepoCubit, newPath);
  }

  Future<void> _pickModeAndMoveEntry(
    RepoCubit? toRepoCubit,
    String toPath,
  ) async {
    if (toRepoCubit == null) {
      await _repoCubit.moveEntry(
        source: path,
        destination: toPath,
      );

      return;
    }

    await _repoCubit.moveEntryToRepo(
      destinationRepoCubit: toRepoCubit,
      type: type,
      source: path,
      destination: toPath,
    );
  }
}
