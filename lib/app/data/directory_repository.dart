import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../models/models.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';

class DirectoryRepository with OuiSyncAppLogger {
  Future<BasicResult> createFile(Repository repository, String newFilePath) async {
    BasicResult createFileResult;
    String error = '';

    File? newFile;
    try {
      loggy.app('Creating file $newFilePath');

      newFile = await File.create(repository, newFilePath);
    } catch (e, st) {
      loggy.app('Creating file $newFilePath exception', e, st);
      error = e.toString();
    }

    createFileResult = CreateFileResult(functionName: 'createFile', result: newFile);
    if (error.isNotEmpty) {
      createFileResult.errorMessage = error;
    }

    return createFileResult;
  }

  Future<BasicResult> writeFile(Repository repository, String filePath, Stream<List<int>> fileStream) async {
    loggy.app('Writing file $filePath');

    BasicResult writeFileResult;
    String error = '';

    final file = await File.open(repository, filePath);
    int offset = 0;

    try {
      await for (final buffer in fileStream) {
        loggy.app('Buffer size: ${buffer.length} - offset: $offset');
        await file.write(offset, buffer);
        offset += buffer.length;
      }
    } catch (e, st) {
      loggy.app('Writing file $filePath', e, st);
      error = 'Writing file $filePath failed';
    } finally {
      loggy.app('Writing file $filePath done - closing');
      await file.close();
    }

    writeFileResult = WriteFileResult(functionName: 'writeFile', result: offset);
    if (error.isNotEmpty) {
      writeFileResult.errorMessage = error;
    }

    return writeFileResult;
  }

  Future<BasicResult> readFile(Repository repository, String filePath, {String action = ''}) async {
    BasicResult readFileResult;
    String error = '';

    final content = <int>[];
    final file = await File.open(repository, filePath);

    try {
      final length = await file.length;
      content.addAll(await file.read(0, length));
    } catch (e, st) {
      loggy.app('Read file $filePath', e, st);
      error = 'Read file $filePath failed';
    } finally {
      file.close();
    }

    readFileResult = action.isEmpty
        ? ReadFileResult(functionName: 'readFile', result: content)
        : ShareFileResult(functionName: 'readFile', result: content, action: action);
    if (error.isNotEmpty) {
      readFileResult.errorMessage = error;
    }

    return readFileResult;
  }
  
  Future<BasicResult> moveEntry(Repository repository, String originPath, String destinationPath) async {
    BasicResult moveEntryResult;
    String error = '';

    try {
      loggy.app('Move entry from $originPath to $destinationPath');

      await repository.move(originPath, destinationPath);
    } catch (e, st) {
      loggy.app('Move entry from $originPath to $destinationPath exception', e, st);
      error = e.toString();
    }

    moveEntryResult = MoveEntryResult(functionName: 'moveEntry', result: destinationPath);
    if (error.isNotEmpty) {
      moveEntryResult.errorMessage = error;
    }

    return moveEntryResult;
  }

  Future<BasicResult> deleteFile(Repository repository, String filePath) async {
    BasicResult deleteFileResult;
    String error = '';

    try {
      await File.remove(repository, filePath);
    } catch (e, st) {
      loggy.app('Delete file $filePath exception', e, st);
      error = 'Delete file $filePath failed';
    }

    deleteFileResult = DeleteFileResult(functionName: 'deleteFile', result: 'OK');
    if (error.isNotEmpty) {
      deleteFileResult.errorMessage = error;
    }

    return deleteFileResult;
  }

  Future<BasicResult> createFolder(Repository repository, String path) async {
    BasicResult createFolderResult;
    String error = '';

    bool created = false;

    try {
      loggy.app('Create folder $path');

      await Directory.create(repository, path);
      created = true;
    } catch (e, st) {
      loggy.app('Create folder $path exception', e, st);

      created = false;
      error = e.toString();
    }

    createFolderResult = CreateFolderResult(functionName: 'createFolder', result: created);
    if (error.isNotEmpty) {
      createFolderResult.errorMessage = error;
    }

    return createFolderResult;
  }

  Future<int> getFileSize(Repository repository, String path) async {
    var file;
    var length = 0;

    try {
      file = await File.open(repository, path);
    } catch (e, st) {
      loggy.app("Open file $path exception (getFileSize)", e, st);
      return length;
    }

    try {
      length = await file.length;
    } catch (e, st) {
      loggy.app("Get file size $path exception", e, st);
    }

    file.close();

    return length;
  }

  Future<List<BaseItem>> getFolderContents(Repository repository, String path) async {
    String? error = null;

    final content = <BaseItem>[];

    final directory = await Directory.open(repository, path);
    final iterator = directory.iterator;

    try {
      while (iterator.moveNext()) {
        var size = 0;
        if (iterator.current.type == EntryType.file) {
          size = await getFileSize(repository, path + '/' + iterator.current.name);
        }
        final item = await _castToBaseItem(path, iterator.current.name, iterator.current.type, size);

        content.add(item);
      }
    } catch (e, st) {
      loggy.app('Traversing directory $path exception', e, st);
      error = e.toString();
    } finally {
      directory.close();
    }

    if (error != null) {
      throw error;
    }

    return content;
  }

  Future<BaseItem> _castToBaseItem(String path, String name, EntryType type, int size) async {
    final itemPath = path == '/' ? '/$name' : '$path/$name';

    if (type == EntryType.directory) {
      return FolderItem(
          name: name,
          path: itemPath,
          size: size);
    }

    if (type == EntryType.file) {
      return FileItem(name: name, path: itemPath, size: size);
    }

    return <BaseItem>[].single;
  }

  Future<BasicResult> deleteFolder(Repository repository, String path, bool recursive) async {
    BasicResult deleteFolderResult;
    String error = '';

    try {
      await Directory.remove(repository, path, recursive: recursive);
    } catch (e, st) {
      loggy.app('Delete folder $path exception', e, st);
      error = 'Delete folder $path failed';
    }

    deleteFolderResult = DeleteFolderResult(functionName: 'deleteFolder', result: 'OK');
    if (error.isNotEmpty) {
      deleteFolderResult.errorMessage = error;
    }

    return deleteFolderResult;
  }
}
