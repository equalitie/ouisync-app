import 'package:flutter/material.dart';

import '../../../callbacks/nativecallbacks.dart';
import '../../controls/controls.dart';
import '../../models/models.dart';

class DirectoryRepository {
  Future<bool> createFolder(String repoDir, String newFolderRelativePath)  async {
    bool creationSuccessful;

    await NativeCallbacks.createDirAsync(repoDir, newFolderRelativePath)
    .catchError((onError) {
      print('Error on createDirAsync call: $onError');
    })
    .then((returned) => {
      creationSuccessful = returned == 0
    })
    .whenComplete(() => {
      print('createFolderAsync completed')
    });

    return creationSuccessful;
  }

  Future<List<BaseItem>> getContents(String repoDir, String folder) async {
    print("About to call readDirAsync...");
    
    List<dynamic> folderContents;
    String folderPath = folder.isEmpty ? repoDir : '$repoDir/$folder';
    
    await NativeCallbacks.readDirAsync(repoDir, folder)
    .catchError((onError) {
      print('Error on readDirAsync call: $onError');
    })
    .then((contents) async {
        print('readDirAsync returned ${contents.length} items');

        var contentsWithAttributes = await _getAttributes(repoDir, contents.cast<String>());
        folderContents = _castToBaseItem(folderPath, contentsWithAttributes);
    })
    .whenComplete(() => {
      print('readDirAsync completed')
    });
    
    if (folderContents.isEmpty) {
      return [];
    }

    return folderContents;
  }

  Future<List<String>> _getAttributes(String repoDir, List<String> paths) async {
    List<String> objectWithAttributes;

    await NativeCallbacks.getAttributesAsync(repoDir, paths)
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
      String name = _extractNativeAttribute(data, 'name').split(':')[1];
      String type = _extractNativeAttribute(data, 'type').split(':')[1];
      double size = 0.0;
      if (data.any((element) => element.startsWith('size:'))) {
       size = double.parse(_extractNativeAttribute(data, 'size').split(':')[1]); 
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
       return FileItem(
          '',
          name,
          '',
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
    attributesList.singleWhere((element) => element.startsWith('$attribute:'));
}