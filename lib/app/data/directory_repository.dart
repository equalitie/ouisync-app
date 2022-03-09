import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../models/models.dart';
import '../utils/utils.dart';

class DirectoryRepository {
  Future<BasicResult> createFile(Repository repository, String newFilePath) async {
    BasicResult createFileResult;
    String error = '';

    File? newFile;
    int? handle;

    try {
      print('Creating file $newFilePath');

      newFile = await File.create(repository, newFilePath);
      handle = newFile.handle;
    } catch (e) {
      print('Error creating file $newFilePath: $e');
      error = e.toString();
    } finally {
      await newFile?.close();
    }

    createFileResult = CreateFileResult(functionName: 'createFile', result: handle);
    if (error.isNotEmpty) {
      createFileResult.errorMessage = error;
    }

    return createFileResult;
  }

  Future<BasicResult> writeFile(Repository repository, String filePath, Stream<List<int>> fileStream) async {
    print('Writing file $filePath');

    BasicResult writeFileResult;
    String error = '';

    final file = await File.open(repository, filePath);
    int offset = 0;

    try {
      await for (final buffer in fileStream) {
        print('Buffer size: ${buffer.length} - offset: $offset');
        await file.write(offset, buffer);
        offset += buffer.length;
      }
    } catch (e) {
      print('Exception writing the file $filePath:\n${e.toString()}');
      error = 'Writing to the file $filePath failed';
    } finally {
      print('Writing file $filePath done - closing');
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
    } catch (e) {
      print('Exception reading file $filePath:\n${e.toString()}');
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
      print('Moving entry from $originPath to $destinationPath');

      await repository.move(originPath, destinationPath);
    } catch (e) {
      print('Error moving entry from $originPath to $destinationPath: $e');
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
    } catch (e) {
      print('Exception deleting file $filePath:\n${e.toString()}');
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
      print('Creating folder $path');

      await Directory.create(repository, path);
      created = true;
    } catch (e) {
      print('Error creating folder $path: $e');

      created = false;
      error = e.toString();
    }

    createFolderResult = CreateFolderResult(functionName: 'createFolder', result: created);
    if (error.isNotEmpty) {
      createFolderResult.errorMessage = error;
    }

    return createFolderResult;
  }

  Future<BasicResult> getFolderContents(Repository repository, String path) async {
    print("Getting folder $path contents");

    BasicResult getContentsResult;
    String error = '';

    final content = <BaseItem>[];

    final directory = await Directory.open(repository, path);
    final iterator = directory.iterator;

    try {
      while (iterator.moveNext()) {
        final item = await _castToBaseItem(path, iterator.current.name, iterator.current.type, 0.0);

        content.add(item);
      }
    } catch (e) {
      print('Error traversing directory $path: $e');
      error = e.toString();
    } finally {
      directory.close();
    }

    getContentsResult = GetContentResult(functionName: 'getFolderContents', result: content);
    if (error.isNotEmpty) {
      getContentsResult.errorMessage = error;
    }

    return getContentsResult;
  }

  Future<List<BaseItem>> getContentsRecursive(Repository repository, String path, List<BaseItem> contentNodes) async {
    final directory = await Directory.open(repository, path);
    try {
      final iterator = directory.iterator;
      while (iterator.moveNext()) {
        final newNode = await _castToBaseItem(path, iterator.current.name, iterator.current.type, 0.0);

        if (newNode.itemType == ItemType.folder) {
          final itemPath = path == '/' ? '/${iterator.current.name}' : '$path/${iterator.current.name}';

          (newNode as FolderItem).items = await getContentsRecursive(repository, itemPath, contentNodes);
        }

        contentNodes.add(newNode);
      }
    } catch (e) {
      print('Error traversing directory $path: $e');
    } finally {
      directory.close();
    }

    return contentNodes;
  }

  Future<BaseItem> _castToBaseItem(String path, String name, EntryType type, double size) async {
    final itemPath = path == '/' ? '/$name' : '$path/$name';

    if (type == EntryType.directory) {
      return FolderItem(
          name: name,
          path: itemPath,
          size: size,
          syncStatus: SyncStatus.idle,
          itemType: ItemType.folder,
          items: <BaseItem>[]);
    }

    if (type == EntryType.file) {
      String fileType = extractFileTypeFromName(name);

      return FileItem(name: name, extension: fileType, path: itemPath, size: size, syncStatus: SyncStatus.idle);
    }

    return <BaseItem>[].single;
  }

  Future<BasicResult> deleteFolder(Repository repository, String path, bool recursive) async {
    BasicResult deleteFolderResult;
    String error = '';

    try {
      await Directory.remove(repository, path, recursive: recursive);
    } catch (e) {
      print('Exception deleting folder $path:\n${e.toString()}');
      error = 'Delete folder $path failed';
    }

    deleteFolderResult = DeleteFolderResult(functionName: 'deleteFolder', result: 'OK');
    if (error.isNotEmpty) {
      deleteFolderResult.errorMessage = error;
    }

    return deleteFolderResult;
  }
}
