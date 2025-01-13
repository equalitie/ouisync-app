import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync_app/app/models/folder.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/utils.dart' show CacheServers, Mounter;
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as repo_path;
import 'package:path/path.dart' as p;
import 'package:ouisync_app/app/cubits/cubits.dart'
    show EntryBottomSheetCubit, EntrySelectionCubit, NavigationCubit, RepoCubit;
import 'package:ouisync_app/app/models/models.dart' show RepoLocation;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';
import 'move_entry_between_repos_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late TestDependencies deps;

  late Repository originRepo;
  late Repository destinationRepo;

  late RepoCubit originRepoCubit;
  late RepoCubit destinationRepoCubit;

  late NativeChannels nativeChannels;

  late Map<
      String,
      ({
        bool isDir,
        bool selected,
        bool? tristate,
      })> expectedFolder1SelectedAll;
  late List<String> expectedFolder1DestinationContents;
  late List<String> expectedFolder1OriginContents;

  late Map<
      String,
      ({
        bool isDir,
        bool selected,
        bool? tristate,
      })> expected2RootFoldersSelectedAll;
  late List<String> expected2RootFoldersDestinationContents;

  late Map<
      String,
      ({
        bool isDir,
        bool selected,
        bool? tristate,
      })> expectedOneFileOnlyFolder1;
  late List<String> expectedOneFileOnyFolder1DestinationContents;
  late List<String> expectedOneFileOnyFolder1OriginContents;

  late Map<
      String,
      ({
        bool isDir,
        bool selected,
        bool? tristate,
      })> expected3FilesSelected;
  late List<String> expecte3FilesdDestinationContents;
  late List<String> expected3FilesOriginContents;

  late Map<
      String,
      ({
        bool isDir,
        bool selected,
        bool? tristate,
      })> expectedSelected1NewFile;
  late List<String> expected1NewFileDestinationContents;
  late List<String> expected1NewFileOriginContentsAll;
  late List<String> expected1NewFileOriginContents;

  late Map<
      String,
      ({
        bool isDir,
        bool selected,
        bool? tristate,
      })> expectedFolder3SelectedAll;
  late List<String> expectedFolder3DestinationContents;
  late List<String> expectedFolder3OriginContentsAll;
  late List<String> expectedFolder3OriginContents;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();

    final locationOrigin =
        RepoLocation.fromDbPath(repo_path.join(dir.path, "store1.db"));
    final locationDestination =
        RepoLocation.fromDbPath(repo_path.join(dir.path, "store2.db"));

    session = Session.create(configPath: dir.path, kind: SessionKind.unique);
    deps = await TestDependencies.create();

    originRepo = await Repository.create(
      session,
      store: locationOrigin.path,
      readSecret: null,
      writeSecret: null,
    );
    destinationRepo = await Repository.create(
      session,
      store: locationDestination.path,
      readSecret: null,
      writeSecret: null,
    );

    PathProviderPlatform.instance = FakePathProviderPlatform(dir);
    nativeChannels = FakeNativeChannels(session);

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});

    final mounter = Mounter(session);

    originRepoCubit = await RepoCubit.create(
      nativeChannels: nativeChannels,
      repo: originRepo,
      session: session,
      location: locationOrigin,
      navigation: NavigationCubit(),
      entrySelection: EntrySelectionCubit(),
      bottomSheet: EntryBottomSheetCubit(),
      cacheServers: CacheServers.disabled,
      mounter: mounter,
    );

    destinationRepoCubit = await RepoCubit.create(
      nativeChannels: nativeChannels,
      repo: destinationRepo,
      session: session,
      location: locationDestination,
      navigation: NavigationCubit(),
      entrySelection: EntrySelectionCubit(),
      bottomSheet: EntryBottomSheetCubit(),
      cacheServers: CacheServers.disabled,
      mounter: mounter,
    );

    // Create 2 folders, 1 nested, in originRepo
    {
      await Directory.create(originRepo, '/folder1');
      await Directory.create(originRepo, 'folder1/folder2');
    }

    // Create files and add to folders
    {
      for (var i = 0; i < 8; i++) {
        final path = i < 4 ? 'folder1' : repo_path.join('folder1', 'folder2');

        final filePath = repo_path.join(path, 'file$i.txt');
        final file = await File.create(originRepo, filePath);
        await file.write(0, utf8.encode("123$i"));
        await file.close();
      }

      final rootContents = await Directory.open(originRepo, '/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await Directory.open(originRepo, 'folder1');
      expect(folder1Contents, hasLength(5));

      final folder2Contents =
          await Directory.open(originRepo, 'folder1/folder2');
      expect(folder2Contents, hasLength(4));
    }

    // Prepare expected contents for move all folder1
    {
      expectedFolder1SelectedAll =
          <String, ({bool isDir, bool selected, bool? tristate})>{
        '/folder1': (isDir: true, selected: true, tristate: true),
        '/folder1/file0.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file1.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file2.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file3.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/folder2': (isDir: true, selected: true, tristate: true),
        '/folder1/folder2/file4.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file5.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file6.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file7.txt': (
          isDir: false,
          selected: true,
          tristate: true
        )
      };

      expectedFolder1DestinationContents = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file1.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
        '/folder1/folder2/file6.txt',
        '/folder1/folder2/file7.txt',
      ];

      expectedFolder1OriginContents = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file1.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
        '/folder1/folder2/file6.txt',
        '/folder1/folder2/file7.txt',
      ];
    }
    // Prepare expected contents for move all 2 root folders
    {
      expected2RootFoldersSelectedAll =
          <String, ({bool isDir, bool selected, bool? tristate})>{
        '/folder1': (isDir: true, selected: true, tristate: true),
        '/folder1/file0.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file1.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file2.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file3.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/folder2': (isDir: true, selected: true, tristate: true),
        '/folder1/folder2/file4.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file5.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file6.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file7.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder4': (isDir: true, selected: true, tristate: true),
        '/folder4/file0.txt': (isDir: false, selected: true, tristate: true),
        '/folder4/file1.txt': (isDir: false, selected: true, tristate: true),
        '/folder4/file2.txt': (isDir: false, selected: true, tristate: true),
      };

      expected2RootFoldersDestinationContents = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file1.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
        '/folder1/folder2/file6.txt',
        '/folder1/folder2/file7.txt',
        '/folder4',
        '/folder4/file0.txt',
        '/folder4/file1.txt',
        '/folder4/file2.txt',
      ];
    }

    // Prepare expected contents for move just /folder1/file1.txt
    {
      expectedOneFileOnlyFolder1 =
          <String, ({bool isDir, bool selected, bool? tristate})>{
        '/folder1': (isDir: true, selected: false, tristate: null),
        '/folder1/file1.txt': (isDir: false, selected: true, tristate: true),
      };

      expectedOneFileOnyFolder1DestinationContents = <String>['/file1.txt'];

      expectedOneFileOnyFolder1OriginContents = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
        '/folder1/folder2/file6.txt',
        '/folder1/folder2/file7.txt',
      ];
    }

    // Prepare expected contents for move 3 files
    {
      expected3FilesSelected =
          <String, ({bool isDir, bool selected, bool? tristate})>{
        '/folder1': (isDir: true, selected: false, tristate: null),
        '/folder1/file1.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/folder2': (isDir: true, selected: false, tristate: null),
        '/folder1/folder2/file6.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file7.txt': (
          isDir: false,
          selected: true,
          tristate: true
        )
      };

      expecte3FilesdDestinationContents = <String>[
        '/file1.txt',
        '/folder2',
        '/folder2/file6.txt',
        '/folder2/file7.txt',
      ];

      expected3FilesOriginContents = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
      ];
    }

    // Prepare expected contents for move 1 new files
    {
      expectedSelected1NewFile =
          <String, ({bool isDir, bool selected, bool? tristate})>{
        '/folder1': (isDir: true, selected: false, tristate: null),
        '/folder1/folder2': (isDir: true, selected: false, tristate: null),
        '/folder1/folder2/folder3': (
          isDir: true,
          selected: false,
          tristate: null
        ),
        '/folder1/folder2/folder3/file0.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
      };
      expected1NewFileDestinationContents = <String>['/file0.txt'];

      expected1NewFileOriginContentsAll = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file1.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
        '/folder1/folder2/file6.txt',
        '/folder1/folder2/file7.txt',
        '/folder1/folder2/folder3',
        '/folder1/folder2/folder3/file0.txt',
        '/folder1/folder2/folder3/file1.txt',
      ];

      expected1NewFileOriginContents = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file1.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
        '/folder1/folder2/file6.txt',
        '/folder1/folder2/file7.txt',
        '/folder1/folder2/folder3',
        '/folder1/folder2/folder3/file1.txt',
      ];
    }

    // Prepare expected contents for move all folder3
    {
      expectedFolder3SelectedAll =
          <String, ({bool isDir, bool selected, bool? tristate})>{
        '/folder1': (isDir: true, selected: false, tristate: null),
        '/folder1/folder2': (isDir: true, selected: false, tristate: true),
        '/folder1/folder3': (isDir: true, selected: true, tristate: true),
        '/folder1/file1.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file3.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/folder2/file4.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file5.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file6.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file7.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder3/file0.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder3/file1.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
      };
    }

    // Prepare expected contents for move all folder3
    {
      expectedFolder3SelectedAll =
          <String, ({bool isDir, bool selected, bool? tristate})>{
        '/folder1': (isDir: true, selected: false, tristate: null),
        '/folder1/folder2': (isDir: true, selected: false, tristate: true),
        '/folder1/folder3': (isDir: true, selected: true, tristate: true),
        '/folder1/file1.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/file3.txt': (isDir: false, selected: true, tristate: true),
        '/folder1/folder2/file4.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file5.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file6.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder2/file7.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder3/file0.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
        '/folder1/folder3/file1.txt': (
          isDir: false,
          selected: true,
          tristate: true
        ),
      };

      expectedFolder3DestinationContents = <String>[
        '/file1.txt',
        '/file3.txt',
        '/folder2',
        '/folder2/file4.txt',
        '/folder2/file5.txt',
        '/folder2/file6.txt',
        '/folder2/file7.txt',
        '/folder3',
        '/folder3/file0.txt',
        '/folder3/file1.txt',
      ];

      expectedFolder3OriginContentsAll = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file1.txt',
        '/folder1/file2.txt',
        '/folder1/file3.txt',
        '/folder1/folder2',
        '/folder1/folder2/file4.txt',
        '/folder1/folder2/file5.txt',
        '/folder1/folder2/file6.txt',
        '/folder1/folder2/file7.txt',
        '/folder1/folder3',
        '/folder1/folder3/file0.txt',
        '/folder1/folder3/file1.txt',
      ];

      expectedFolder3OriginContents = <String>[
        '/folder1',
        '/folder1/file0.txt',
        '/folder1/file2.txt',
        '/folder1/folder2',
      ];
    }
  });

  tearDown(() async {
    await originRepo.close();
    await destinationRepo.close();

    await deps.dispose();
    await session.close();
  });

  testWidgets(
    'Copy all entries from one repo to another repo',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Select folder1 selects all its contents
        {
          await _selectEntries(
            originRepoCubit,
            [DirectoryEntry(path: '/folder1')],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(10));

          // Expect first entry to be /folder1. isDir: true, selected: true, tristate: true
          expect(selectedEntries.keys.first, equals('/folder1'));
          expect(selectedEntries.values.first.isDir, equals(true));
          expect(selectedEntries.values.first.selected, equals(true));
          expect(selectedEntries.values.first.tristate, equals(true));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedFolder1SelectedAll));
        }

        // Copy all entries form origin to destination root
        {
          final result =
              await originRepoCubit.entrySelectionCubit.copyEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the contents copied to destination root
          expect(destinationContents, expectedFolder1DestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expectedFolder1DestinationContents);
        }
      },
    ),
  );

  testWidgets(
    'Move all entries from one repo to another repo, then copy them back',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Select folder1 selects all its contents
        {
          await _selectEntries(
            originRepoCubit,
            [DirectoryEntry(path: '/folder1')],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(10));

          // Expect first entry to be /folder1. isDir: true, selected: true, tristate: true
          expect(selectedEntries.keys.first, equals('/folder1'));
          expect(selectedEntries.values.first.isDir, equals(true));
          expect(selectedEntries.values.first.selected, equals(true));
          expect(selectedEntries.values.first.tristate, equals(true));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedFolder1SelectedAll));
        }

        // Move all entries form origin to destination root
        {
          final result =
              await originRepoCubit.entrySelectionCubit.moveEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the contents moved to destination root
          expect(destinationContents, expectedFolder1DestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          );

          // Expect no entries left in origin after moving to destination
          expect(originContents.isEmpty, equals(true));
        }

        // Select all the entries in the destination
        {
          await _selectEntries(
            destinationRepoCubit,
            [DirectoryEntry(path: '/folder1')],
          );

          final selectedEntries =
              destinationRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(10));

          // Expect first entry to be /folder1. isDir: true, selected: true, tristate: true
          expect(selectedEntries.keys.first, equals('/folder1'));
          expect(selectedEntries.values.first.isDir, equals(true));
          expect(selectedEntries.values.first.selected, equals(true));
          expect(selectedEntries.values.first.tristate, equals(true));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedFolder1SelectedAll));
        }

        // Copy all entries form destination back to origin root
        {
          final result =
              await destinationRepoCubit.entrySelectionCubit.copyEntriesTo(
            context,
            destinationRepoCubit: originRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the contents copied back to origin root
          expect(destinationContents, expectedFolder1DestinationContents);

          final originContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in destination
          expect(originContents, expectedFolder1DestinationContents);
        }
      },
    ),
  );

  testWidgets(
    'Copy all entries from one repo to another repo, with two folders selected in root',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Add one extra folder, /folder1/folder2/folder3, 2 files to new folder
        await _addFolderWithFiles(
          originRepo,
          newDirPath: '/folder4',
          files: 3,
        );

        // Select folder1, folder4, selects all its contents
        {
          await _selectEntries(
            originRepoCubit,
            [
              DirectoryEntry(path: '/folder1'),
              DirectoryEntry(path: '/folder4'),
            ],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(14));

          // Expect first entry to be /folder1. isDir: true, selected: true, tristate: true
          expect(selectedEntries.keys.first, equals('/folder1'));
          expect(selectedEntries.values.first.isDir, equals(true));
          expect(selectedEntries.values.first.selected, equals(true));
          expect(selectedEntries.values.first.tristate, equals(true));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expected2RootFoldersSelectedAll));
        }

        // Copy all entries form origin to destination root
        {
          final result =
              await originRepoCubit.entrySelectionCubit.copyEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the contents copied to destination root, /folder1, /folder4
          expect(destinationContents, expected2RootFoldersDestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expected2RootFoldersDestinationContents);
        }
      },
    ),
  );

  testWidgets(
    'Move all entries from one repo to another repo, with two folders selected in root',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        // Add one extra root folder, /folder4, 3 files to new folder: /folder4/file4-6.txt
        await _addFolderWithFiles(
          originRepo,
          newDirPath: '/folder4',
          files: 3,
        );

        // Select folder1 selects all its contents
        {
          await _selectEntries(
            originRepoCubit,
            [
              DirectoryEntry(path: '/folder1'),
              DirectoryEntry(path: '/folder4'),
            ],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(14));

          // Expect first entry to be /folder1. isDir: true, selected: true, tristate: true
          expect(selectedEntries.keys.first, equals('/folder1'));
          expect(selectedEntries.values.first.isDir, equals(true));
          expect(selectedEntries.values.first.selected, equals(true));
          expect(selectedEntries.values.first.tristate, equals(true));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expected2RootFoldersSelectedAll));
        }

        // Move all entries form origin to destination root
        {
          final result =
              await originRepoCubit.entrySelectionCubit.moveEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the contents moved to destination root, /folder1, /folder4
          expect(destinationContents, expected2RootFoldersDestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          );

          // Expect no entries left in origin after moving to destination
          expect(originContents.isEmpty, equals(true));
        }
      },
    ),
  );

  testWidgets(
    'Copy one file from one repo to another repo, no folder selected',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        // Select just file1.txt, selects /folder1, /folder1/file1.txt
        {
          await _selectEntries(
            originRepoCubit,
            [FileEntry(path: '/folder1/file1.txt', size: 0)],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 2 selected: /folder1, /folder1/file1.txt
          expect(selectedEntries, hasLength(2));

          // Expect selected: /folder1, /folder1/file1.txt
          expect(selectedEntries, equals(expectedOneFileOnlyFolder1));
        }

        // Move just file1.txt, /folder1 is not moved
        {
          final result =
              await originRepoCubit.entrySelectionCubit.copyEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only file1.txt copied to destination root
          expect(
            destinationContents,
            expectedOneFileOnyFolder1DestinationContents,
          );

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expectedFolder1OriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Move one file from one repo to another repo, no folder selected',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        // Select just file1.txt, selects /folder1, /folder1/file1.txt
        {
          await _selectEntries(
            originRepoCubit,
            [FileEntry(path: '/folder1/file1.txt', size: 0)],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 2 selected: /folder1, /folder1/file1.txt
          expect(selectedEntries, hasLength(2));

          // Expect selected: /folder1, /folder1/file1.txt
          expect(selectedEntries, equals(expectedOneFileOnlyFolder1));
        }

        // Move just file1.txt, /folder1 is not moved
        {
          final result =
              await originRepoCubit.entrySelectionCubit.moveEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only file1.txt moved to destination root
          expect(
            destinationContents,
            expectedOneFileOnyFolder1DestinationContents,
          );

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only file1.txt removed from origin contents
          expect(originContents, expectedOneFileOnyFolder1OriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Select 3 files, then copy them from one repo to another repo root',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Select 3 files /folder1/file1.txt, /folder1/folder2/file6,7.txt, subfolder /folder1/folder2 selected
        {
          await _selectEntries(
            originRepoCubit,
            [
              FileEntry(path: '/folder1/file1.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file6.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file7.txt', size: 0),
            ],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 5 selected: /folder1, /folder1/file1.txt, /folder1/folder2, /folder1/folder2/file6,7.txt
          expect(selectedEntries, hasLength(5));

          // Expect selected: /folder1, /folder1/file1.txt, /folder1/folder2, /folder1/folder2/file6,7.txt
          expect(selectedEntries, equals(expected3FilesSelected));
        }

        // Copy selected files to destination root
        {
          final result =
              await originRepoCubit.entrySelectionCubit.copyEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only selected files copied to destination root: /folder1/file1.txt, /folder1/folder2/file6,.txt ; one parent folder /folder1/folder2
          expect(destinationContents, expecte3FilesdDestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expectedFolder1OriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Select 3 files, then move them from one repo to another repo root',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Select 3 files /folder1/file1.txt, /folder1/folder2/file6,7.txt, subfolder /folder1/folder2 selected
        {
          await _selectEntries(
            originRepoCubit,
            [
              FileEntry(path: '/folder1/file1.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file6.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file7.txt', size: 0),
            ],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 5 selected: /folder1, /folder1/file1.txt, /folder1/folder2, /folder1/folder2/file6,7.txt
          expect(selectedEntries, hasLength(5));

          // Expect selected: /folder1, /folder1/file1.txt, /folder1/folder2, /folder1/folder2/file6,7.txt
          expect(selectedEntries, equals(expected3FilesSelected));
        }

        // Move selected files to destination root
        {
          final result =
              await originRepoCubit.entrySelectionCubit.moveEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only selected files moved to destination root: /folder1/file1.txt, /folder1/folder2/file6,.txt ; one parent folder /folder1/folder2
          expect(destinationContents, expecte3FilesdDestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only selected files removed from origin contents
          expect(originContents, expected3FilesOriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Add one extra subfolder, two files, and copy just one of the new files from one repo to another repo',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Add one extra folder, /folder1/folder2/folder3, 2 files to new folder
        await _addFolderWithFiles(
          originRepo,
          newDirPath: 'folder1/folder2/folder3',
          files: 2,
        );

        // Select /folder1/folder2/folder3/file0.txt
        {
          await _selectEntries(
            originRepoCubit,
            [FileEntry(path: '/folder1/folder2/folder3/file0.txt', size: 0)],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 4 selected: /folder1, /folder1/folder2/, /folder1/folder2/folder3, /folder1/folder2/folder3/file0.txt
          expect(selectedEntries, hasLength(4));

          // Expect selected: /folder1, /folder1/folder2, /folder1/folder2/folder3, /folder1/folder2/folder3/file0.txt
          expect(selectedEntries, equals(expectedSelected1NewFile));
        }

        // Copy all selected entries form repo
        {
          final result =
              await originRepoCubit.entrySelectionCubit.copyEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only selected file copied to destination root
          expect(destinationContents, expected1NewFileDestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expected1NewFileOriginContentsAll);
        }
      },
    ),
  );

  testWidgets(
    'Add one extra subfolder, two files, and move just one of the new files from one repo to another repo',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Add one extra folder, /folder1/folder2/folder3, 2 files to new folder
        await _addFolderWithFiles(
          originRepo,
          newDirPath: 'folder1/folder2/folder3',
          files: 2,
        );

        // Select /folder1/folder2/folder3/file0.txt
        {
          await _selectEntries(
            originRepoCubit,
            [FileEntry(path: '/folder1/folder2/folder3/file0.txt', size: 0)],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 4 selected: /folder1, /folder1/folder2/, /folder1/folder2/folder3, /folder1/folder2/folder3/file0.txt
          expect(selectedEntries, hasLength(4));

          // Expect selected: /folder1, /folder1/folder2, /folder1/folder2/folder3, /folder1/folder2/folder3/file0.txt
          expect(selectedEntries, equals(expectedSelected1NewFile));
        }

        // Move all selected entries form repo
        {
          final result =
              await originRepoCubit.entrySelectionCubit.moveEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only selected file moved to destination root
          expect(destinationContents, expected1NewFileDestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only selected file removed from origin contents
          expect(originContents, expected1NewFileOriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Add extra entries and copy from one repo to another repo. Select all of /folder1/folder2 contents, select /folder1/folder3',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Add one extra subfolder, /folder1/folder3, add 2 files to new folder
        await _addFolderWithFiles(
          originRepo,
          newDirPath: '/folder1/folder3',
          files: 2,
        );

        //Select all files in /folder1/folder2; select /folder1/folder3/, selects all its contents
        {
          await _selectEntries(
            originRepoCubit,
            [
              FileEntry(path: '/folder1/file1.txt', size: 0),
              FileEntry(path: '/folder1/file3.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file4.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file5.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file6.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file7.txt', size: 0),
              DirectoryEntry(path: '/folder1/folder3'),
            ],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 11 selected: /folder1, /folder1/folder2, /folder1/folder2/folder3, /folder1/file1,3.txt, , /folder1/folder2/file4-7.txt, folder1/folder3/file0,1.txt
          expect(selectedEntries, hasLength(11));

          // Expect all selected: /folder1, /folder1/file1,3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedFolder3SelectedAll));
        }

        // Copy all selected entries form repo
        {
          final result =
              await originRepoCubit.entrySelectionCubit.copyEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect file1,3.txt, /folder2, /folder2/4,7.txt, /folder3, /folder3/file0,1.txt moved to destination root
          expect(destinationContents, expectedFolder3DestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expectedFolder3OriginContentsAll);
        }
      },
    ),
  );

  testWidgets(
    'Add extra entries and move from one repo to another repo. Select all of /folder1/folder2 contents, select /folder1/folder3',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Add one extra subfolder, /folder1/folder3, add 2 files to new folder
        await _addFolderWithFiles(
          originRepo,
          newDirPath: '/folder1/folder3',
          files: 2,
        );

        //Select all files in /folder1/folder2; select /folder1/folder3/, selects all its contents
        {
          await _selectEntries(
            originRepoCubit,
            [
              FileEntry(path: '/folder1/file1.txt', size: 0),
              FileEntry(path: '/folder1/file3.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file4.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file5.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file6.txt', size: 0),
              FileEntry(path: '/folder1/folder2/file7.txt', size: 0),
              DirectoryEntry(path: '/folder1/folder3'),
            ],
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 11 selected: /folder1, /folder1/folder2, /folder1/folder2/folder3, /folder1/file1,3.txt, , /folder1/folder2/file4-7.txt, folder1/folder3/file0,1.txt
          expect(selectedEntries, hasLength(11));

          // Expect all selected: /folder1, /folder1/file1,3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedFolder3SelectedAll));
        }

        // Move all selected entries form repo
        {
          final result =
              await originRepoCubit.entrySelectionCubit.moveEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

          final destinationContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect file1,3.txt, /folder2, /folder2/4,7.txt, /folder3, /folder3/file0,1.txt moved to destination root
          expect(destinationContents, expectedFolder3DestinationContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only selected files removed from origin contents
          expect(originContents, expectedFolder3OriginContents);
        }
      },
    ),
  );
}

Future<void> _selectEntries(
  RepoCubit cubit,
  List<FileSystemEntry> entries,
) async {
  final repoInfoHash = await cubit.infoHash;
  await cubit.startEntriesSelection();
  for (var entry in entries) {
    await cubit.entrySelectionCubit.selectEntry(repoInfoHash, entry);
  }
}

Future<void> _addFolderWithFiles(
  Repository cubit, {
  required String newDirPath,
  required int files,
}) async {
  {
    await Directory.create(cubit, newDirPath);

    for (var i = 0; i < files; i++) {
      final filePath = p.join(
        newDirPath,
        'file$i.txt',
      );
      final file = await File.create(cubit, filePath);
      await file.write(0, utf8.encode("123$i"));
      await file.close();
    }
  }
}

Future<List<FileSystemEntry>> _getPathContents(
  RepoCubit cubit,
  String path,
  List<FileSystemEntry> entries,
) async {
  final contents = await cubit.getFolderContents(path);
  for (var c in contents) {
    entries.add(c);
    if (c is DirectoryEntry) {
      await _getPathContents(cubit, c.path, entries);
    }
  }

  return entries;
}
