import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/utils/settings.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart' as p;

void main() {
  late Session session;
  late RepoCubit repository;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    session = await Session.open(dir.path);

    final settings = await Settings.init();
    final info = RepoMetaInfo.fromDbPath(p.join(dir.path, "store.db"));

    repository = RepoCubit(
        metaInfo: info,
        handle: await Repository.create(
          session,
          store: info.path(),
          readPassword: null,
          writePassword: null,
        ),
        settings: settings);
  });

  tearDown(() async {
    await repository.close();
    session.close();
  });

  test('Move folder ok when folder to move is empty', () async {
    const folder1Path = '/folder1';
    const folder2Path = '/folder1/folder2';
    const folder2RootPath = '/folder2';
    final folder1ExpectedContents = [
      FolderItem(
        name: 'folder2',
        path: folder2Path,
      )
    ];
    final rootExpectedContentsWithFolder1AndFolder2 = [
      FolderItem(
        name: 'folder1',
        path: folder1Path,
      ),
      FolderItem(
        name: 'folder2',
        path: folder2RootPath,
      )
    ];

    // Create folder1 (/folder1)
    {
      final result = await repository.createFolder(folder1Path);
      expect(result, equals(true));
    }
    // Create folder2 inside folder2 (/folder1/folder2)
    {
      final result = await repository.createFolder(folder2Path);
      expect(result, equals(true));
    }
    // Get contents of folder1 (/folder1) and confirm it contains folder2 (/folder1/folder2)
    {
      final folder1Contents = await repository.getFolderContents(folder1Path);
      expect(folder1Contents, equals(folder1ExpectedContents));
    }
    // Move folder2 (/folder1/folder2) to root (/folder2)
    {
      final result = await repository.moveEntry(
          source: folder2Path, destination: folder2RootPath);
      expect(result, equals(true));
    }

    {
      final rootContentsAfterMovingFolder2 =
          await repository.getFolderContents('/');
      expect(rootContentsAfterMovingFolder2,
          equals(rootExpectedContentsWithFolder1AndFolder2));
    }
  });

  test('Move folder ok when folder to move is not empty', () async {
    const folder1Path = '/folder1';
    const folder2Path = '/folder1/folder2';
    const folder2RootPath = '/folder2';
    const file1InFolder2Path = '/folder1/folder2/file1.txt';
    const filePathContent = 'hello world';
    final folder1ExpectedContents = [
      FolderItem(
        name: 'folder2',
        path: folder2Path,
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
      ),
      FolderItem(
        name: 'folder2',
        path: folder2RootPath,
      )
    ];

    // Create folder1 (/folder1)
    {
      final result = await repository.createFolder(folder1Path);
      expect(result, equals(true));
    }
    // Create folder2 inside folder2 (/folder1/folder2)
    {
      final result = await repository.createFolder(folder2Path);
      expect(result, equals(true));
    }
    // Create file1 inside folder2 (/folder1/folder2)
    {
      final file = await File.create(repository.handle, file1InFolder2Path);
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
      final result = await repository.moveEntry(
          source: folder2Path, destination: folder2RootPath);
      expect(result, equals(true));
    }

    {
      final rootContentsAfterMovingFolder2 =
          await repository.getFolderContents('/');
      expect(rootContentsAfterMovingFolder2,
          equals(rootExpectedContentsWithFolder1AndFolder2));
    }
  });
}
