import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

import '../../controls/controls.dart';
import '../../models/models.dart';

class OuisyncRepository {
  void createRepository() {
    // String path = '$repoDir/$newRepoPath';
    // OuiSync.initializeRepository(path);
  }

  Future<List<BaseItem>> getRepositories() async {
    // print('Reading user repositories at $repoDir');
    
    // bool exist = await Directory(repoDir).exists();
    // if(!exist) {
    //   print('Repository location $repoDir doesn\'t exist');
    //   return [];
    // }

    List<BaseItem> reposList = [];
    
    // await Directory(repoDir).list().toList()
    // .catchError((onError) {
    //   print('Error reading $repoDir contents: $onError');
    // })
    // .then((repos) => {
    //     print('Repositories found: ${repos.length}'),
    //     reposList = _castToBaseItem(repos)
    // })
    // .whenComplete(() => {
    //   print('Done reading repositories')
    // });
    
    return reposList;
  }

  List<BaseItem> _castToBaseItem(List<FileSystemEntity> repos) {
    List<BaseItem> newList = repos.map((repo) => 
      FolderItem(
        name: getPathFromFileName(repo.path),
        path: repo.path,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        itemType: ItemType.repo,
        icon: Icons.store, 
        items: [],
        
      )
    ).toList();

    return newList;
  }
  
  
}