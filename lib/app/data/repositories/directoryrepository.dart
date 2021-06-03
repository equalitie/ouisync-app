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

  Future<BasicResult> createFile(Repository repository, String newFilePath) async {
    print('Creating file $newFilePath');
    
    BasicResult createFileResult;
    String error = '';

    File newFile;

    await File.create(repository, newFilePath)
    .catchError((onError) {
      print('Error creating file $newFilePath: $onError');
      error = onError;
    })
    .then((file) => newFile = file);

    createFileResult = CreateFileResult(functionName: 'createFile', result: newFile);
    if (error.isNotEmpty) {
      createFileResult.errorMessage = error;
    }

    return createFileResult;
  }

  Future<BasicResult> writeFile(Repository repository, String filePath, Stream<List<int>> fileStream) async {
    print('Writing file $filePath');
    
    BasicResult writeFileResult;
    String error = '';

    int offset = 0;
    // int totalBytes = 0;

    final file = await File.open(repository, filePath);

    try {
      final streamReader = ChunkedStreamIterator(fileStream);
      while (true) {
        var buffer = await streamReader.read(File.defaultChunkSize);
        print('Buffer size: ${buffer.length} - offset: $offset');

        print('Buffer:\n$buffer');

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
    }

    writeFileResult = WriteFileResult(functionName: 'writeFile', result: file);
    if (error.isNotEmpty) {
      writeFileResult.errorMessage = error;
    }

    return writeFileResult; 
  }

  Future<void> readFile(Repository repository, String filePath) async {
    // List<int> fileStream = new List.filled(0, 0, growable: true);
    // await for (var chunk in OuiSync.readFile(repoDir, filePath, bufferSize, totalBytes.toInt())) {
    //   if (chunk == EndOfFile) {
    //     break;
    //   }

    //   print('Chunk received: ${chunk.length} bytes');
    //   fileStream.addAll(chunk);
    // }

    // final imfs = MemoryFileSystem(); //InMemoryFileSystem
    // final tempDirectory = await imfs.systemTempDirectory.create();
    // final outputFile = tempDirectory.childFile('testFile.pdf');
    // outputFile.writeAsBytes(fileStream);

    // // print(outputFile.read());

    // final _result = await OpenFile.open(outputFile.path);
    // print(_result.message);
  }

  Future<BasicResult> getContents(Repository repository, String path, bool recursive) async {
    print("Getting folder $path contents in repository $repository");
  
    if (recursive) {
      print('(recursive...)');

      List<Node> returnedContent = await getContentsRecursive(repository, path);

      // await _getContentsRecursive(repository, path)
      // .catchError((onError) {
      //   print('Error on getContentsRecursive call: $onError');
      // })
      // .then((value) => {
      //   returnedContent.addAll(value)
      // })
      // .whenComplete(() => {
      //   print('getContentsRecursive completed')
      // });

      return GetContentRecursiveResult(functionName: 'getContents', result: returnedContent);
    }

    return await _getFolderContents(repository, path);
  }

  Future<BasicResult> _getFolderContents(Repository repository, String path) async {
    BasicResult getContentsResult;
    String error = '';

    List<BaseItem> returnedContent = [];

    final directory = await Directory.open(repository, path);
    try {
      final iterator = directory.iterator;
      while (iterator.moveNext()) {
        final item = iterator.current;
        returnedContent.add(
          _castToBaseItem(
            path,
            item.name,
            item.type,
            0.0
          )
        );
      }  
    } catch (e) {
      print('Error traversing directory $path: $e');
      error = e.toString();
    } finally {
      print('Directory $path closed');
      directory.close();
    }
    
    getContentsResult = GetContentResult(functionName: 'getContents', result: returnedContent);
    if (error.isNotEmpty) {
      getContentsResult.errorMessage = error;
    }

    return getContentsResult;
  }

  Future<List<Node>> getContentsRecursive(Repository repository, String path) async {
    List<Node> nodes = new List.filled(0, null, growable: true);

    final directory = await Directory.open(repository, path);
    if (directory.isEmpty) {
      print('Folder $path is empty.');
      return [];
    }

    try {
      final iterator = directory.iterator;
      while (iterator.moveNext()) {
        final item = iterator.current;
        nodes.add(await _castToTreeView(repository, path, item));
      }  
    } catch (e) {
      print('Error traversing directory $path: $e');
    } finally {
      print('Directory $path closed');
      directory.close();
    }

    return nodes;
  }

  Future<Node> _castToTreeView(Repository repository, String parentPath, DirEntry entry) async {
    Node node;
    var item = _castToBaseItem(parentPath, entry.name, entry.type, 0.0);

    if (item == null) {
      return null;
    }

    if (item is FileItem) {
      node = Node(
        label: item.name,
        key: 'file',
        icon: Icons.insert_drive_file,
        data: FileDescription(fileData: item)
      );
    }

    if (item is FolderItem) {
      var path = item.path == '/'
      ? '/${item.name}'
      : '${item.path}/${item.name}';

      node = Node(
        parent: true,
        label: item.name,
        key: item.name,
        icon: Icons.folder,
        data: FolderDescription(folderData: item),
        children: await getContentsRecursive(repository, path),
      );
    }

    return node;
  }

  BaseItem _castToBaseItem(String path, String name, EntryType type, double size) {
    if (type == EntryType.directory) {
      return FolderItem(
        "",
        name,
        path,
        size,
        SyncStatus.idle,
        User(id: '', name: ''),
        itemType: ItemType.folder,
        icon: Icons.store,
      );
    }

    if (type == EntryType.file) {
      String fileType = extractFileTypeFromName(name);

      return FileItem(
        '',
        name,
        fileType,
        path,
        0.0,
        SyncStatus.idle,
        User(id: '', name: '')
      ); 
    }
    
    return null;
  }
}