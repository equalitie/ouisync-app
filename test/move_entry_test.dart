import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/data/data.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

void main() {
  late Session session;
  late Repository repository;

  late DirectoryRepository directoryRepository;

  setUp(() async {
    session = await Session.open(':memory:');
    repository = await Repository.create(session, store: ':memory:', password: 'a1b2c3');

    directoryRepository = DirectoryRepository(); 
  });

  tearDown(() {
    repository.close();
    session.close();
  });

  test('Move folder ok when folder to move is empty',
  () async {
    final folder1Path = '/folder1';
    final folder2Path = '/folder1/folder2';
    final folder2RootPath = '/folder2';
    final folder1ExpectedContents = [
      FolderItem(
        name: 'folder2',
        path: folder2Path,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        itemType: ItemType.folder,
        items: <BaseItem>[]
      )
    ];
    final rootExpectedContentsWithFolder1AndFolder2 = [
      FolderItem(
        name: 'folder1',
        path: folder1Path,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        itemType: ItemType.folder,
        items: <BaseItem>[]
      ),
      FolderItem(
        name: 'folder2',
        path: folder2RootPath,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        itemType: ItemType.folder,
        items: <BaseItem>[]
      )
    ];

    // Create folder1 (/folder1)
    {
      final resultFolder1Creation = await directoryRepository.createFolder(repository, folder1Path);
      expect(resultFolder1Creation.functionName, equals('createFolder'));
      expect(resultFolder1Creation.errorMessage, isEmpty);
      expect(resultFolder1Creation.result, equals(true));
    }
    // Create folder2 inside folder2 (/folder1/folder2)
    {
      final resultFolder2Creation = await directoryRepository.createFolder(repository, folder2Path);
      expect(resultFolder2Creation.functionName, equals('createFolder'));
      expect(resultFolder2Creation.errorMessage, isEmpty);
      expect(resultFolder2Creation.result, equals(true));
    }
    // Get contents of folder1 (/folder1) and confirm it contains folder2 (/folder1/folder2)
    {
      final folder1Contents = await directoryRepository.getFolderContents(repository, folder1Path);
      expect(folder1Contents.functionName, equals('getFolderContents'));
      expect(folder1Contents.errorMessage, isEmpty);
      expect(folder1Contents.result, equals(folder1ExpectedContents));

      print(folder1Contents.result);
    }
    // Move folder2 (/folder1/folder2) to root (/folder2)
    {
      final moveFolder2ToRoot = await directoryRepository.moveEntry(repository, folder2Path, folder2RootPath);
      expect(moveFolder2ToRoot.functionName, equals('moveEntry'));
      expect(moveFolder2ToRoot.errorMessage, isEmpty);
      expect(moveFolder2ToRoot.result, equals(folder2RootPath));

      print('folder2 new path: ${moveFolder2ToRoot.result}');
    }

    {
      final rootContentsAfterMovingFolder2 = await directoryRepository.getFolderContents(repository, '/');
      expect(rootContentsAfterMovingFolder2.functionName, equals('getFolderContents'));
      expect(rootContentsAfterMovingFolder2.errorMessage, isEmpty);
      expect(rootContentsAfterMovingFolder2.result, equals(rootExpectedContentsWithFolder1AndFolder2));

      print(rootContentsAfterMovingFolder2.result);
    }
  });

  test('Move folder ok when folder to move is not empty',
  () async {
    final folder1Path = '/folder1';
    final folder2Path = '/folder1/folder2';
    final folder2RootPath = '/folder2';
    final file1InFolder2Path = '/folder1/folder2/file1.txt';
    final filePathContent = 'hello world';
    final folder1ExpectedContents = [
      FolderItem(
        name: 'folder2',
        path: folder2Path,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        itemType: ItemType.folder,
        items: <BaseItem>[]
      )
    ];
    final folder2WithFile1ExpectedContents = [
      FileItem(
        name: 'file1.txt',
        extension: 'txt',
        path: file1InFolder2Path,
        size: 0.0,
        syncStatus: SyncStatus.idle
      )
    ];
    final rootExpectedContentsWithFolder1AndFolder2 = [
      FolderItem(
        name: 'folder1',
        path: folder1Path,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        itemType: ItemType.folder,
        items: <BaseItem>[]
      ),
      FolderItem(
        name: 'folder2',
        path: folder2RootPath,
        size: 0.0,
        syncStatus: SyncStatus.idle,
        itemType: ItemType.folder,
        items: <BaseItem>[
          FileItem(
            name: 'file1.txt',
            extension: 'txt',
            path: file1InFolder2Path,
            size: 0.0,
            syncStatus: SyncStatus.idle
          )
        ]
      )
    ];

    // Create folder1 (/folder1)
    {
      final resultFolder1Creation = await directoryRepository.createFolder(repository, folder1Path);
      expect(resultFolder1Creation.functionName, equals('createFolder'));
      expect(resultFolder1Creation.errorMessage, isEmpty);
      expect(resultFolder1Creation.result, equals(true));
    }
    // Create folder2 inside folder2 (/folder1/folder2)
    {
      final resultFolder2Creation = await directoryRepository.createFolder(repository, folder2Path);
      expect(resultFolder2Creation.functionName, equals('createFolder'));
      expect(resultFolder2Creation.errorMessage, isEmpty);
      expect(resultFolder2Creation.result, equals(true));
    }
    // Create file1 inside folder2 (/folder1/folder2)
    {
      final file = await File.create(repository, file1InFolder2Path);
      await file.write(0, utf8.encode(filePathContent));
      await file.close();
      
    }
    // Get contents of folder1 (/folder1) and confirm it contains folder2 (/folder1/folder2)
    {
      final folder1Contents = await directoryRepository.getFolderContents(repository, folder1Path);
      expect(folder1Contents.functionName, equals('getFolderContents'));
      expect(folder1Contents.errorMessage, isEmpty);
      expect(folder1Contents.result, equals(folder1ExpectedContents));

      print(folder1Contents.result);
    }
    // Get contents of folder2 (/folder1/folder2) and confirm it contains file1.txt (/folder1/folder2/file1.txt)
    {
      final folder2Contents = await directoryRepository.getFolderContents(repository, folder2Path);
      expect(folder2Contents.functionName, equals('getFolderContents'));
      expect(folder2Contents.errorMessage, isEmpty);
      expect(folder2Contents.result, equals(folder2WithFile1ExpectedContents));

      print(folder2Contents.result);
    }
    // Move folder2 (/folder1/folder2) to root (/folder2) containing file1.txt (/folder1/folder2/file1.txt)
    {
      final moveFolder2ToRoot = await directoryRepository.moveEntry(repository, folder2Path, folder2RootPath);
      expect(moveFolder2ToRoot.functionName, equals('moveEntry'));
      expect(moveFolder2ToRoot.errorMessage, isEmpty);
      expect(moveFolder2ToRoot.result, equals(folder2RootPath));

      print('folder2 new path: ${moveFolder2ToRoot.result}');
    }

    {
      final rootContentsAfterMovingFolder2 = await directoryRepository.getFolderContents(repository, '/');
      expect(rootContentsAfterMovingFolder2.functionName, equals('getFolderContents'));
      expect(rootContentsAfterMovingFolder2.errorMessage, isEmpty);
      expect(rootContentsAfterMovingFolder2.result, equals(rootExpectedContentsWithFolder1AndFolder2));

      print(rootContentsAfterMovingFolder2.result);
    }
  });
}