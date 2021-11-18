import 'package:fluttertoast/fluttertoast.dart';
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
      _showToast(message, length);
    }

    return exist;
  }

  void _showToast(String message, Toast? length) => Fluttertoast
  .showToast(
    msg: message,
    toastLength: length,
  );

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
      print('File legth: $path is not a file.');
      return -1;
    }

    File? file;
    int length = 0;
    try {
      file = await File.open(_repository, path);
      length = await file.length;
    } catch (e) {
      print('Error getting the length for file $path:\n${e.toString()}');
    } finally {
      if (file != null) {
        file.close(); 
      }      
    }
    
    return length;
  }
}