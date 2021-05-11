import 'dart:io';
import 'dart:typed_data';

import 'package:chunked_stream/chunked_stream.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync.dart';

import '../../controls/controls.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class DirectoryRepository {
  Future<BasicResult> createFolder(String repoDir, String newFolderRelativePath)  async {
    print('Creating folder $newFolderRelativePath in repository $repoDir');
    
    BasicResult createFolderResult;

    await OuiSync.newFolder(repoDir, newFolderRelativePath)
    .catchError((onError) {
      print('Error on createDirAsync call: $onError');
    })
    .then((returned) => {
      createFolderResult = CreateFolderResult(
        functionName: 'createFolder',
        result: returned == 0
      )
    })
    .whenComplete(() => {
      print('createFolderAsync completed')
    });

    return createFolderResult;
  }

  Future<BasicResult> createFile(String repoDir, String newFilePath) async {
    print('Creating file $newFilePath');
    
    BasicResult createFileResult;

    await OuiSync.newFile(repoDir, newFilePath)
    .catchError((onError) {
      print('Error on createFileAsync call: $onError');
    })
    .then((result) {
      createFileResult = CreateFileResult(functionName: 'createFile', result: result);
      if (result != 'OK') {
        createFileResult.errorMessage = result;
      } 
    })
    .whenComplete(() => {
      print('createFileAsync completed')
    });

    return createFileResult;
  }

  Future<BasicResult> writeFile(String repoDir, String filePath, Stream<List<int>> fileStream) async {
    print('Writing file $filePath');
    
    BasicResult writeFileResult;
    String error = '';

    int totalBytes = 0;
    int offset = 0;

    try {
      final streamReader = ChunkedStreamIterator(fileStream);

      while (true) {
        var buffer = await streamReader.read(bufferSize);
        print('Buffer size: ${buffer.length} - offset: $offset');

        print('Buffer:\n$buffer');

        if (buffer.isEmpty) {
          print('The buffer is empty; reading from the stream is done!\nTotal bytes read: $totalBytes');
          break;
        }

        var bytesRead = await OuiSync.writeFile(repoDir, filePath, buffer, offset);
        totalBytes += bytesRead;

        print('Bytes read: $bytesRead');

        offset += bytesRead;
      }
    } catch (e) {
      print('Exception writing the fie $filePath:\n${e.toString()}');
      error = 'Writing to the file $filePath failed';
    }

    writeFileResult = WriteFileResult(functionName: 'writeFile', result: totalBytes);
    if (error.isNotEmpty) {
      writeFileResult.errorMessage = error;
    }

    return writeFileResult; 
  }

  Future<void> readFile(String repoDir, String filePath, double totalBytes) async {
    List<int> fileStream = new List.filled(0, 0, growable: true);
    await for (var chunk in OuiSync.readFile(repoDir, filePath, bufferSize, totalBytes.toInt())) {
      if (chunk == EndOfFile) {
        break;
      }

      print('Chunk received: ${chunk.length} bytes');
      fileStream.addAll(chunk);
    }

    File inMemoryFile = File.fromRawPath(Uint8List.fromList(fileStream));
  }

  Future<BasicResult> getContents(String repoDir, String parentPath) async {
    print("Getting folder $parentPath contents in repository $repoDir");
    
    BasicResult getContentsResult;

    List<BaseItem> returnedContents = [];
    String error = '';
    
    /* If there is not parent folder, it means we are in the repository root,
      so the path for the folder is the repository path.
      Otherwise, we need to pass the full path for the new folder 
    */
    String folderPath = parentPath.isEmpty
    ? repoDir
    : '$repoDir/$parentPath';
    
    await OuiSync.readFolder(repoDir, parentPath)
    .catchError((onError) {
      print('Error on readDirAsync call: $onError');
    })
    .then((contents) async {
      print('readDirAsync returned ${contents.length} items');

      if (contents.isEmpty) {
        return;
      }
      
      if (contents.first == 'ERROR') {
        error = contents.last;
        return;
      }

      final paths = contents.cast<String>().map(
        (object) => parentPath.isEmpty 
        ? object
        : '$parentPath/$object'
      ).toList();

      var contentsWithAttributes = await _getAttributes(repoDir, paths);
      returnedContents = _castToBaseItem(folderPath, contentsWithAttributes);
    })
    .whenComplete(() => {
      print('readDirAsync completed')
    });
    
    getContentsResult = GetContentResult(functionName: 'getContents', result: returnedContents);
    if (error.isNotEmpty) {
      getContentsResult.errorMessage = error;
    }

    return getContentsResult;
  }

  Future<List<String>> _getAttributes(String repoDir, List<String> paths) async {
    List<String> objectWithAttributes;

    await OuiSync.getObjectAttributes(repoDir, paths)
    .catchError((onError) {
      print('Error on getAttributesAsync call: $onError');
    })
    .then((returned) => {
      print('getAttributes: $returned'),
      objectWithAttributes = List<String>.from(returned)
    })
    .whenComplete(() => {
      print('getAttributesAsync completed')
    });

    if (objectWithAttributes.isEmpty) {
      return [];
    }

    return objectWithAttributes;
  }

  List<BaseItem> _castToBaseItem(String folderPath, List<String> objectWithAttributes) {
    List<BaseItem> newList = objectWithAttributes.map((object) { 
      List<String> data = object.split(',');

      String name = _extractNativeAttribute(data, 'name').toString().split('/').last;
      String type = _extractNativeAttribute(data, 'type');
      
      double size = 0.0;
      if (data.any((element) => element.startsWith('size:'))) {
       size = double.parse(_extractNativeAttribute(data, 'size')); 
      }

      if (type == 'folder') {
        return FolderItem(
          "",
          name,
          folderPath,
          size,
          SyncStatus.idle,
          User(id: '', name: ''),
          itemType: ItemType.folder,
          icon: Icons.store,
        );
      }

      if (type == 'file') {
        String fileType = _extractFileTypeFromName(name);

        return FileItem(
          '',
          name,
          fileType,
          folderPath,
          size,
          SyncStatus.idle,
          User(id: '', name: '')
        ); 
      }
    }).toList().cast<BaseItem>();

    return newList;
  }

  dynamic _extractNativeAttribute(List<String> attributesList, String attribute) => 
    attributesList.singleWhere((element) => element.startsWith('$attribute:')).split(':')[1];

  String _extractFileTypeFromName(String fileName) {
    //TODO
  }
}