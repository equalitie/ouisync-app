import 'package:chunked_stream/chunked_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../controls/controls.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class DirectoryRepository {
  _openRepository(session) async => 
    await Repository.open(session);

  _openDirectory(repository, path) async => 
    await Directory.open(repository, path);

  _openFile(repository, path) async => 
    await File.open(repository, path);

  Future<BasicResult> createFolder(Session session, String path)  async {
    BasicResult createFolderResult;
    String error = '';

    bool created = false;
    final repository = await _openRepository(session);

    try {
      print('Creating folder $path');

      await Directory.create(repository, path);
      created = true;
    } catch (e) {
      print('Error creating folder $path: $e');

      created = false;
      error = e.toString();
    } finally {
      repository.close();
    }

    createFolderResult = CreateFolderResult(functionName: 'createFolder', result: created);
    if (error.isNotEmpty) {
      createFolderResult.errorMessage = error;
    }

    return createFolderResult;
  }

  Future<BasicResult> createFile(Session session, String newFilePath) async {
    BasicResult createFileResult;
    String error = '';

    File? newFile;
    final repository = await _openRepository(session);

    try {
      print('Creating file $newFilePath');

      newFile = await File.create(repository, newFilePath);
    } catch (e) {
      print('Error creating file $newFilePath: $e');
      error = e.toString();
    } finally {
      newFile!.close(); // TODO: Necessary? 
      repository.close();
    }

    createFileResult = CreateFileResult(functionName: 'createFile', result: newFile);
    if (error.isNotEmpty) {
      createFileResult.errorMessage = error;
    }

    return createFileResult;
  }

  Future<BasicResult> writeFile(Session session, String filePath, Stream<List<int>> fileStream) async {
    print('Writing file $filePath');
    
    BasicResult writeFileResult;
    String error = '';

    int offset = 0;

    final repository = await _openRepository(session);
    final file = await _openFile(repository, filePath);

    try {
      final streamReader = ChunkedStreamIterator(fileStream);
      while (true) {
        final buffer = await streamReader.read(bufferSize);
        print('Buffer size: ${buffer.length} - offset: $offset');

        if (buffer.isEmpty) {
          print('The buffer is empty; reading from the stream is done!');
          break;
        }

        await file.write(offset, buffer);
        offset += buffer.length;
      }
    } catch (e) {
      print('Exception writing the fie $filePath:\n${e.toString()}');
      error = 'Writing to the file $filePath failed';
    } finally {
      file.close();
      repository.close();
    }

    writeFileResult = WriteFileResult(functionName: 'writeFile', result: file);
    if (error.isNotEmpty) {
      writeFileResult.errorMessage = error;
    }

    return writeFileResult; 
  }

  Future<BasicResult> readFile(Session session, String filePath, { String action = '' }) async {
    BasicResult readFileResult;
    String error = '';

    final repository = await _openRepository(session);
    final file = await _openFile(repository, filePath);
    
    final content = <int>[];

    try {
      final length = await file.length;
      content.addAll(await file.read(0, length));  
    } catch (e) {
      print('Exception reading file $filePath:\n${e.toString()}');
      error = 'Read file $filePath failed';
    } finally {
      file.close();
      repository.close();
    }

    readFileResult = action.isEmpty
    ? ReadFileResult(functionName: 'readFile', result: content)
    : ShareFileResult(functionName: 'readFile', result: content, action: action);
    if (error.isNotEmpty) {
      readFileResult.errorMessage = error;
    }

    return readFileResult;
  }

  Future<BasicResult> deleteFile(Session session, String filePath) async {
    BasicResult deleteFileResult;
    String error = '';

    final repository = await _openRepository(session);

    try {
      await File.remove(repository, filePath);
    } catch (e) {
      print('Exception deleting file $filePath:\n${e.toString()}');
      error = 'Delete file $filePath failed';
    } finally {
      repository.close();
    }

    deleteFileResult = DeleteFileResult(functionName: 'deleteFile', result: 'OK');
    if (error.isNotEmpty) {
      deleteFileResult.errorMessage = error;
    }

    return deleteFileResult;
  }

  Future<BasicResult> getContents(Session session, String path, bool recursive) async {
    print("Getting folder $path contents");
  
    if (recursive) {
      print('(recursive...)');

      List<Node> returnedContent = await getContentsRecursive(session, path);
      BasicResult getContentsRecursiveResult = GetContentRecursiveResult(
        functionName: '_getContentsRecursive',
        result: returnedContent
      );

      return getContentsRecursiveResult;
    }

    return await _getFolderContents(session, path);
  }

  Future<BasicResult> _getFolderContents(Session session, String path) async {
    BasicResult getContentsResult;
    String error = '';

    final returnedContent = <BaseItem>[];

    final repository = await _openRepository(session);
    final directory = await _openDirectory(repository, path);
    
    try {
      final iterator = directory.iterator;
      while (iterator.moveNext()) {
        returnedContent.add(
          _castToBaseItem(
            path,
            iterator.current.name,
            iterator.current.type,
            0.0
          )!
        );
      } 
    } catch (e) {
      print('Error traversing directory $path: $e');
      error = e.toString();
    } finally {
      directory.close();
      repository.close();
    }
    
    getContentsResult = GetContentResult(functionName: '_getFolderContents', result: returnedContent);
    if (error.isNotEmpty) {
      getContentsResult.errorMessage = error;
    }

    return getContentsResult;
  }

  Future<List<Node>> getContentsRecursive(Session session, String path) async {
    final contentNodes = <Node>[];

    final repository = await _openRepository(session);
    final directory = await _openDirectory(repository, path);

    if (directory.isEmpty) {
      print('Folder $path is empty.');

      directory.close();
      repository.close();

      return <Node>[];
    }

    try {
      final iterator = directory.iterator;
      while (iterator.moveNext()) {
        final newNode = await _castToTreeView(
          session,
          path,
          iterator.current
        );

        contentNodes.add(newNode!);
      }  
    } catch (e) {
      print('Error traversing directory $path: $e');
    } finally {
      directory.close();
      repository.close();
    }

    return contentNodes;
  }

  Future<Node?> _castToTreeView(Session session, String parentPath, DirEntry entry) async {
    final item = _castToBaseItem(parentPath, entry.name, entry.type, 0.0);

    if (item == null) {
      return null;
    }

    if (item is FileItem) {
      return Node(
        label: item.name,
        key: 'file',
        icon: Icons.insert_drive_file,
        data: FileDescription(fileData: item)
      );
    }

    if (item is FolderItem) {
      return Node(
        parent: true,
        label: item.name,
        key: item.name,
        icon: Icons.folder,
        data: FolderDescription(folderData: item),
        children: await getContentsRecursive(session, item.path),
      );
    }
  }

  BaseItem? _castToBaseItem(String path, String name, EntryType type, double size) {
    final itemPath = path == '/'
    ? '/$name'
    : '$path/$name';

    if (type == EntryType.directory) {
      return FolderItem(
        id: '',
        name: name,
        path: itemPath,
        size: size,
        syncStatus: SyncStatus.idle,
        user: User(id: '', name: ''),
        itemType: ItemType.folder,
        icon: Icons.store,
        creationDate: DateTime.now(),
        lastModificationDate: DateTime.now(),
        items: <BaseItem>[]
      );
    }

    if (type == EntryType.file) {
      String fileType = extractFileTypeFromName(name);

      return FileItem(
        id: '',
        name: name,
        extension: fileType,
        path: itemPath,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        user: User(id: '', name: ''),
        creationDate: DateTime.now(),
        lastModificationDate: DateTime.now()
      ); 
    }
    
    return null;
  }
}