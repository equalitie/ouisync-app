import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import 'loggers/ouisync_app_logger.dart';
import 'utils.dart';

class EntryInfo with OuiSyncAppLogger {
  const EntryInfo(
    this._repository
  );

  final Repository _repository;

  Future<bool> exist(BuildContext context, {
    required String path
  }) async {
    final exist = await _repository.exists(path);
    if (exist) {
      final type = await _repository.type(path);
      final typeNameForMessage = _getTypeNameForMessage(type);
      
      showSnackBar(context, content: Text(S.current.messageEntryAlreadyExist(typeNameForMessage)));
    }

    return exist;
  }

  String _getTypeNameForMessage(EntryType? type) {
    if (type == null) {
      loggy.app('Entry type was null');
      return S.current.messageEntryTypeDefault;
    }

    return type == EntryType.directory
    ? S.current.messageEntryTypeFolder
    : S.current.messageEntryTypeFile;
  }

  String typeName(EntryType type) {
    return type == EntryType.directory
    ? S.current.typeFolder
    : S.current.typeFile;
  } 

  Future<int> fileLength(String path) async {
    File? file;
    int length = 0;
    try {
      file = await File.open(_repository, path);
      length = await file.length;
    } catch (e, st) {
      loggy.app('Get file length for $path exception', e, st);
      length = -1;
    }

    await file?.close();
    
    return length;
  }

  Future<bool> isDirectoryEmpty(BuildContext context, {
    required String path
  }) async {
    final type = await _repository.type(path);
    if (type != EntryType.directory) {
      loggy.app('Is directory empty: $path is not a directory.');
      return false;
    }

    final Directory directory = await Directory.open(_repository, path);
    if (directory.isNotEmpty) {
      String message = S.current.messageErrorPathNotEmpty(path);
      showSnackBar(context, content: Text(message));
    }
    return directory.isEmpty;
  }
}
