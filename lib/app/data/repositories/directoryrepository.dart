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
    .then((contents) => {
        print('readDirAsync returned ${contents.length} items'),
        folderContents = _castToBaseItem(folderPath, contents.cast<String>())
    })
    .whenComplete(() => {
      print('readDirAsync completed')
    });
    
    if (folderContents.isEmpty) {
      return [];
    }

    return folderContents;
  }

  List<BaseItem> _castToBaseItem(String folderPath, List<String> repos) {
    List<BaseItem> newList = repos.map((repo) => 
      FolderItem(
        "",
        repo,
        folderPath,
        0.0,
        SyncStatus.idle,
        User(id: '', name: ''),
        itemType: ItemType.repo,
        icon: Icons.store,
      )
    ).toList();

    return newList;
  }
}