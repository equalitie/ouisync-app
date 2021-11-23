import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/data/data.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

void main() {
  late Session session;
  late Repository repository;

  late Subscription subscription;

  late DirectoryRepository directoryRepository;
  late String currentPath;

  final folder1Path = '/folder1';
  final file1InFolder1Path = '/folder1/file1.txt';

  setUp(() async {
    session = await Session.open(':memory:');
    repository = await Repository.open(session, ':memory:');

    directoryRepository = DirectoryRepository(); 

    currentPath = '/';

    subscription = repository.subscribe(() async {
      print('Syncing $currentPath');
      await directoryRepository.getFolderContents(repository, currentPath);
    });
  });

  tearDown(() {
    subscription.cancel();

    repository.close();
    session.close();
  });

  test('Add file to directory while syncing other directory',
  () async {
    final file1Content = 'Lorem ipsum dolor sit amet.';

    final folder1ExpectedContentsWithFile1 = [
      FileItem(
        name: 'file1.txt',
        extension: 'txt',
        path: file1InFolder1Path,
        size: 0.0,
        syncStatus: SyncStatus.idle
      )
    ];

    // Create folder1 (/folder1)
    {
      final resultFolder1Creation = await directoryRepository.createFolder(repository, folder1Path);
      expect(resultFolder1Creation.functionName, equals('createFolder'));
      expect(resultFolder1Creation.errorMessage, isEmpty);
      expect(resultFolder1Creation.result, equals(true));
    }
    // Create file1 inside folder2 (/folder1/file1.txt)
    {
      print('About to create file $file1InFolder1Path');
      final file = await File.create(repository, file1InFolder1Path);
      await file.write(0, utf8.encode(file1Content));
      await file.close();
    }
    // Get contents of folder1 (/folder1) and confirm it contains file1.txt (/folder1/file1.txt)
    {
      final folder1Contents = await directoryRepository.getFolderContents(repository, folder1Path);
      expect(folder1Contents.functionName, equals('getFolderContents'));
      expect(folder1Contents.errorMessage, isEmpty);
      expect(folder1Contents.result, equals(folder1ExpectedContentsWithFile1));

      print(folder1Contents.result);
    }
  });

  test('Add file to directory while syncing directory',
  () async {
    final file1Content = 'Lorem ipsum dolor sit amet.';

    final folder1ExpectedContentsWithFile1 = [
      FileItem(
        name: 'file1.txt',
        extension: 'txt',
        path: file1InFolder1Path,
        size: 0.0,
        syncStatus: SyncStatus.idle
      )
    ];

    // Create folder1 (/folder1)
    {
      final resultFolder1Creation = await directoryRepository.createFolder(repository, folder1Path);
      expect(resultFolder1Creation.functionName, equals('createFolder'));
      expect(resultFolder1Creation.errorMessage, isEmpty);
      expect(resultFolder1Creation.result, equals(true));

      currentPath = folder1Path;
    }
    // Create file1 inside folder2 (/folder1/file1.txt)
    {
      print('About to create file $file1InFolder1Path');
      final file = await File.create(repository, file1InFolder1Path);
      await file.write(0, utf8.encode(file1Content));
      await file.close();
    }
    // Get contents of folder1 (/folder1) and confirm it contains file1.txt (/folder1/file1.txt)
    {
      final folder1Contents = await directoryRepository.getFolderContents(repository, folder1Path);
      expect(folder1Contents.functionName, equals('getFolderContents'));
      expect(folder1Contents.errorMessage, isEmpty);
      expect(folder1Contents.result, equals(folder1ExpectedContentsWithFile1));

      print(folder1Contents.result);
    }
  });
}