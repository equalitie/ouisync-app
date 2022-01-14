import 'package:fluttertoast/fluttertoast.dart';
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
      String message = '${_getTypeNameForMessage(type)} with the same name already exist';
      showToast(message, length: Toast.LENGTH_LONG);
    }

    return exist;
  }

  String _getTypeNameForMessage(EntryType? type) {
    if (type == null) {
      return Strings.messageEntryTypeDefault;
    }

    return type == EntryType.directory
    ? Strings.messageEntryTypeFolder
    : Strings.messageEntryTypeFile;
  }

  String typeName(EntryType type) {
    return type == EntryType.directory
    ? Strings.entryTypeFolder
    : Strings.entryTypeFile;
  } 

  Future<int> fileLength(String path) async {
    final type = await _repository.type(path);
    if (type != EntryType.file) {
      print('File length: $path is not a file.');
      return -1;
    }

    File? file;
    int length = 0;
    try {
      file = await File.open(_repository, path);
      length = await file.length;
    } catch (e) {
      print('Error getting the length for file $path:\n${e.toString()}');
    }

    if (file != null) {
      file.close(); 
    }
    
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
      String message = Strings.messageErrorPathNotEmpty
      .replaceAll(
        Strings.replacementPath,
        path
      );
      showToast(message, length: Toast.LENGTH_LONG);
    }
    return directory.isEmpty;
  }
}