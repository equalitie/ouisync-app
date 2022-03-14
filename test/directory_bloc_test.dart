import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/data/directory_repository.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

class FakeFile extends Fake implements File {}
class FakeFileStream extends Fake implements Stream<List<int>> {}

@GenerateMocks([DirectoryRepository])
void main() {
  group('DirectoryBloc', () {
    late Session session;
    late Repository repository;

    late DirectoryRepository directoryRepository;
    late DirectoryBloc directoryBloc;

    late FileItem dummyFileItem;

    late Stream<List<int>> stream;
    String loremIpsum = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

    setUp(() async {
      session = await Session.open(":memory:");
      repository = await Repository.create(session, store: ":memory:", password: '1a2b3c');

      directoryRepository = new DirectoryRepository();
      directoryBloc = DirectoryBloc(directoryRepository: directoryRepository);

      dummyFileItem = FileItem(
        name: 'testFile.txt',
        path: '/testFile.txt',
        extension: 'txt',
      );
    });

    tearDown(() {
      directoryBloc.close();

      repository.close();
      session.close();
    });

    group('CreateFolder', () {
        blocTest('emits [DirectoryLoadInProgress, NavigationLoadSuccess] when CreateFolder is added and createFolder succeeds',
        build: () => directoryBloc,
        act: (DirectoryBloc bloc) => bloc.add(CreateFolder(repository: repository, parentPath: '/', newFolderPath: '/test')),
        wait: Duration(seconds: 1),
        expect: () => [
          DirectoryLoadInProgress(),
          NavigationLoadSuccess(type: Navigation.content, origin: '/', destination: '/test', contents: <BaseItem>[])
        ]);
        // TODO: find out what is the expected behaviour in the library for this: create directory '//' .
        // blocTest('emits [DirectoryLoadInProgress, DirectoryLoadFailure] with message when CreateFolder is added '
        // 'and createFolder fails',
        // build: () => directoryBloc,
        // act: (DirectoryBloc bloc) => bloc.add(CreateFolder(repository: repository, parentPath: '/', newFolderPath: '//')),
        // expect: () => [
        //   DirectoryLoadInProgress(),
        //   DirectoryLoadFailure()
        // ]);
    });

    group('DeleteFolder', () {
      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when DeleteFolder is added and deleteFolder succeeds', 
      setUp: () async { await Directory.create(repository, '/testFolder'); },
      build: () => directoryBloc,
      act: (DirectoryBloc bloc) => bloc.add(DeleteFolder(repository: repository, parentPath: '/', path: '/testFolder')),
      wait: Duration(seconds: 1),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadSuccess(path: '/', contents: <BaseItem>[])
      ]);

      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadFailure] when DeleteFolder is added and deleteFolder fails'
      ' because the folder do not exist',
      build: () => directoryBloc,
      act: (DirectoryBloc bloc) => bloc.add(DeleteFolder(repository: repository, parentPath: '/', path: '/testFolder')),
      wait: Duration(seconds: 1),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadFailure()
      ]);
    });

    // TODO: the library is not loading
    // group('SaveFile', () {
    //   blocTest('emit [DirectoryLoadInProgress, DirectoryLoadSuccess] when Savefile is added, createFile is called, '
    //    'if successful, then writeFile is called',
    //   setUp: () {
    //     stream = Stream.value(utf8.encode(loremIpsum));
    //   },
    //   build: () => directoryBloc,
    //   act: (DirectoryBloc bloc) => bloc.add(
    //     SaveFile(
    //       repository: repository,
    //       newFilePath: '/testFile.txt',
    //       fileName: 'testFile.txt',
    //       length: 1,
    //       fileByteStream: stream
    //     )),
    //   expect: () => [
    //     CreateFileDone(fileName: 'testFile.txt', path: '/testFile.txt', extension: 'txt'),
    //     WriteToFileInProgress(path: '/testFile.txt', fileName: 'testFile.txt', length: 1),
    //     WriteToFileDone(filePath: '/testFile.txt', fileName: 'testFile.txt', length: 1)
    //   ]);
    // });
    // TODO: Find out why it's not working.
    // group('ReadFile', () {
    //   blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when ReadFile is added, action is empty (read) '
    //   'and readFile succeds',
    //   setUp: () async {
    //     final file = await File.create(repository, '/testFile.txt');
    //     await file.write(0, utf8.encode(loremIpsum));
    //     await file.close();
    //   },
    //   build: () => directoryBloc,
    //   act: (DirectoryBloc bloc) => bloc.add(
    //     ReadFile(
    //       repository: repository,
    //       parentPath: '/',
    //       filePath: '/testFile.txt',
    //       action: ''
    //     )),
    //   expect: () => [
    //     DirectoryLoadInProgress(),
    //     DirectoryLoadSuccess(path: '/', contents: utf8.encode(loremIpsum), action: '')
    //   ]);

    group('DeleteFile', () {
      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when DeleteFile is added,'
      'deleteFile is called and if successful, then getContentFolder is called and succeeds ',
      setUp: () async {
        final file = await File.create(repository, '/testFile.txt');
        await file.write(0, utf8.encode(loremIpsum));
        await file.close();
      },
      wait: Duration(seconds: 1),
      build: () => directoryBloc,
      act: (DirectoryBloc bloc) => bloc.add(
        DeleteFile(
          repository: repository, 
          parentPath: '/', 
          filePath: '/testFile.txt'
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadSuccess(path: '/', contents: <BaseItem>[])
      ]);
    });

  });
}
