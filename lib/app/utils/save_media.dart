import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoCubit;
import '../widgets/widgets.dart'
    show RenameOrReplaceResult, RenameOrReplaceEntryDialog;
import 'stage.dart';
import 'utils.dart' show AppLogger, disambiguateEntryName;

class SaveMedia with AppLogger {
  SaveMedia(
    BuildContext context, {
    required RepoCubit repoCubit,
    required this.sourcePath,
    required this.type,
    required this.stage,
  }) : _repoCubit = repoCubit;

  final RepoCubit _repoCubit;
  final String sourcePath;
  final EntryType type;
  final Stage stage;

  Future<void> save() async {
    final newFileName = p.basename(sourcePath);
    final newFilePath = p.join(
      _repoCubit.state.currentFolder.path,
      newFileName,
    );

    final exist = await _repoCubit.entryExists(newFilePath);
    if (!exist) {
      await _saveFile(
        devicePath: sourcePath,
        toPath: newFilePath,
        fileName: newFileName,
      );

      return;
    }

    final result = await RenameOrReplaceEntryDialog.show(
      stage: stage,
      title: S.current.actionSave,
      entryName: newFileName,
      entryType: EntryType.file,
    );

    switch (result) {
      case RenameOrReplaceResult.replace:
        await _replaceFile(devicePath: sourcePath, toPath: newFilePath);
      case RenameOrReplaceResult.rename:
        await _renameAndSaveFile(
          devicePath: sourcePath,
          toPath: newFilePath,
          fileName: newFileName,
        );
      case null:
        break;
    }
  }

  Future<void> _saveFile({
    required String devicePath,
    required String toPath,
    required String fileName,
  }) async {
    final file = io.File(devicePath);
    final length = (await file.stat()).size;
    final fileByteStream = file.openRead();

    await _repoCubit.saveFile(
      filePath: toPath,
      length: length,
      fileByteStream: fileByteStream,
    );
  }

  Future<void> _replaceFile({
    required String devicePath,
    required String toPath,
  }) async {
    try {
      final file = io.File(devicePath);
      final fileLength = (await file.stat()).size;
      final fileByteStream = file.openRead();

      await _repoCubit.replaceFile(
        filePath: toPath,
        length: fileLength,
        fileByteStream: fileByteStream,
      );
    } catch (e, st) {
      loggy.debug(e, st);
    }
  }

  Future<void> _renameAndSaveFile({
    required String devicePath,
    required String toPath,
    required String fileName,
  }) async {
    final newPath = await disambiguateEntryName(
      repoCubit: _repoCubit,
      path: toPath,
    );

    await _saveFile(
      devicePath: devicePath,
      toPath: newPath,
      fileName: fileName,
    );
  }
}
