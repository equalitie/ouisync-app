import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/repo_state.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

void main() {
  late Session session;
  late RepoState repository;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    session = await Session.open(dir.path);
    repository = RepoState(
      "dummy_name",
      await Repository.create(session, store: '${dir.path}/store.db', password: 'a1b2c3')
    );
  });

  tearDown(() async {
    await repository.close();
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
        size: 0,
      )
    ];
    final rootExpectedContentsWithFolder1AndFolder2 = [
      FolderItem(
        name: 'folder1',
        path: folder1Path,
        size: 0,
      ),
      FolderItem(
        name: 'folder2',
        path: folder2RootPath,
        size: 0,
      )
    ];

    // Create folder1 (/folder1)
    {
      final resultFolder1Creation = await repository.createFolder(folder1Path);
      expect(resultFolder1Creation.functionName, equals('createFolder'));
      expect(resultFolder1Creation.errorMessage, isEmpty);
      expect(resultFolder1Creation.result, equals(true));
    }
    // Create folder2 inside folder2 (/folder1/folder2)
    {
      final resultFolder2Creation = await repository.createFolder(folder2Path);
      expect(resultFolder2Creation.functionName, equals('createFolder'));
      expect(resultFolder2Creation.errorMessage, isEmpty);
      expect(resultFolder2Creation.result, equals(true));
    }
    // Get contents of folder1 (/folder1) and confirm it contains folder2 (/folder1/folder2)
    {
      final folder1Contents = await repository.getFolderContents(folder1Path);
      expect(folder1Contents, equals(folder1ExpectedContents));
    }
    // Move folder2 (/folder1/folder2) to root (/folder2)
    {
      final moveFolder2ToRoot = await repository.moveEntry(folder2Path, folder2RootPath);
      expect(moveFolder2ToRoot.functionName, equals('moveEntry'));
      expect(moveFolder2ToRoot.errorMessage, isEmpty);
      expect(moveFolder2ToRoot.result, equals(folder2RootPath));
    }

    {
      final rootContentsAfterMovingFolder2 = await repository.getFolderContents('/');
      expect(rootContentsAfterMovingFolder2, equals(rootExpectedContentsWithFolder1AndFolder2));
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
        size: 0,
      )
    ];
    final folder2WithFile1ExpectedContents = [
      FileItem(
        name: 'file1.txt',
        path: file1InFolder2Path,
        size: filePathContent.length,
      )
    ];
    final rootExpectedContentsWithFolder1AndFolder2 = [
      FolderItem(
        name: 'folder1',
        path: folder1Path,
        size: 0,
      ),
      FolderItem(
        name: 'folder2',
        path: folder2RootPath,
        size: 0,
      )
    ];

    // Create folder1 (/folder1)
    {
      final resultFolder1Creation = await repository.createFolder(folder1Path);
      expect(resultFolder1Creation.functionName, equals('createFolder'));
      expect(resultFolder1Creation.errorMessage, isEmpty);
      expect(resultFolder1Creation.result, equals(true));
    }
    // Create folder2 inside folder2 (/folder1/folder2)
    {
      final resultFolder2Creation = await repository.createFolder(folder2Path);
      expect(resultFolder2Creation.functionName, equals('createFolder'));
      expect(resultFolder2Creation.errorMessage, isEmpty);
      expect(resultFolder2Creation.result, equals(true));
    }
    // Create file1 inside folder2 (/folder1/folder2)
    {
      final file = await File.create(repository.repo, file1InFolder2Path);
      await file.write(0, utf8.encode(filePathContent));
      await file.close();
      
    }
    // Get contents of folder1 (/folder1) and confirm it contains folder2 (/folder1/folder2)
    {
      final folder1Contents = await repository.getFolderContents(folder1Path);
      expect(folder1Contents, equals(folder1ExpectedContents));
    }
    // Get contents of folder2 (/folder1/folder2) and confirm it contains file1.txt (/folder1/folder2/file1.txt)
    {
      final folder2Contents = await repository.getFolderContents(folder2Path);
      expect(folder2Contents, equals(folder2WithFile1ExpectedContents));
    }
    // Move folder2 (/folder1/folder2) to root (/folder2) containing file1.txt (/folder1/folder2/file1.txt)
    {
      final moveFolder2ToRoot = await repository.moveEntry(folder2Path, folder2RootPath);
      expect(moveFolder2ToRoot.functionName, equals('moveEntry'));
      expect(moveFolder2ToRoot.errorMessage, isEmpty);
      expect(moveFolder2ToRoot.result, equals(folder2RootPath));

      print('folder2 new path: ${moveFolder2ToRoot.result}');
    }

    {
      final rootContentsAfterMovingFolder2 = await repository.getFolderContents('/');
      expect(rootContentsAfterMovingFolder2, equals(rootExpectedContentsWithFolder1AndFolder2));
    }
  });
}
