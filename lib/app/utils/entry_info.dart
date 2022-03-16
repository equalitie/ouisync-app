import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'utils.dart';

class EntryInfo {
  const EntryInfo(
    this._repository
  );

  final Repository _repository;

  Future<bool> exist({
    required String path,
    Toast? length
  }) async {
    final exist = await _repository.exists(path);
    if (exist) {
      final type = await _repository.type(path);
      final typeNameForMessage = _getTypeNameForMessage(type);
      
      showToast(S.current.messageEntryAlreadyExist.toString().replaceAll(Strings.replacementEntry, typeNameForMessage), length: Toast.LENGTH_LONG);
    }

    return exist;
  }

  String _getTypeNameForMessage(EntryType? type) {
    if (type == null) {
      print('Entry type was null');
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
    } catch (e) {
      print('Error getting the length for file $path:\n${e.toString()}');
      length = -1;
    }

    await file?.close();
    
    return length;
  }

  Future<bool> isDirectoryEmpty({
    required String path,
    Toast? length
  }) async {
    final type = await _repository.type(path);
    if (type != EntryType.directory) {
      print('Is directory empty: $path is not a directory.');
      return false;
    }

    final Directory directory = await Directory.open(_repository, path);
    if (directory.isNotEmpty) {
      String message = S.current.messageErrorPathNotEmpty.toString()
      .replaceAll(
        Strings.replacementPath,
        path
      );
      showToast(message, length: Toast.LENGTH_LONG);
    }
    return directory.isEmpty;
  }
}