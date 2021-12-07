import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

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
      return 'An entry';
    }

    return type == EntryType.directory
    ? 'A directory'
    : 'A file';
  }

  String typeName(EntryType type) {
    return type == EntryType.directory
    ? 'Directory'
    : 'File';
  } 

  Future<int> fileLength(String path) async {
    final type = await _repository.type(path);
    if (type != EntryType.file) {
      print('File length: $path is not a file.');
      return -1;
    }

    int length = 0;
    try {
      final file = await File.open(_repository, path);
      length = await file.length;
      file.close(); 
    } catch (e) {
      print('Error getting the length for file $path:\n${e.toString()}');
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
      String message = '$path is not empty';
      showToast(message, length: Toast.LENGTH_LONG);
    }
    return directory.isEmpty;
  }
}