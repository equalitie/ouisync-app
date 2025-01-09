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
  });

  tearDown(() async {
    await originRepo.close();
    await destinationRepo.close();

    await deps.dispose();
    await session.close();
  });

  testWidgets(
    'Move all entries from one repo to another repo, then copy them back',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        final originRepoInfoHash = await originRepo.infoHash;
        final destinationRepoInfoHash = await destinationRepo.infoHash;

        final expectedFolder1SelectedAll =
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

        final expectedDestinationContents = <String>[
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

        //Select folder1 selects all its contents
        {
          await originRepoCubit.startEntriesSelection();

          final dirEntry = DirectoryEntry(path: '/folder1');
          await originRepoCubit.entrySelectionCubit.selectEntry(
            originRepoInfoHash,
            dirEntry,
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

          final destinationContents = await _getDestinationContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(destinationContents, expectedDestinationContents);

          // Expect no entries left in origin after moving to destination
          final originContents = await _getDestinationContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          );
          expect(originContents.isEmpty, equals(true));
        }

        // Select all the entries in the destination
        {
          await destinationRepoCubit.startEntriesSelection();

          final dirEntry = DirectoryEntry(path: '/folder1');
          await destinationRepoCubit.entrySelectionCubit.selectEntry(
            destinationRepoInfoHash,
            dirEntry,
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

          final destinationContents = await _getDestinationContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(destinationContents, expectedDestinationContents);

          // Expect no entries left in origin after moving to destination
          final originContents = await _getDestinationContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(originContents, expectedDestinationContents);
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

        final repoInfoHash = await originRepo.infoHash;

        // Select just file1.txt, selects /folder1, /folder1/file1.txt
        {
          await originRepoCubit.startEntriesSelection();

          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/file1.txt', size: 0),
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 2 selected: /folder1, /folder1/file1.txt
          expect(selectedEntries, hasLength(2));

          // Expect selected: /folder1, /folder1/file1.txt
          final expectedFolder1SelectedAll =
              <String, ({bool isDir, bool selected, bool? tristate})>{
            '/folder1': (isDir: true, selected: false, tristate: null),
            '/folder1/file1.txt': (
              isDir: false,
              selected: true,
              tristate: true
            ),
          };

          expect(selectedEntries, equals(expectedFolder1SelectedAll));
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

          final expectedDestinationContents = <String>['/file1.txt'];

          final destinationContents = await _getDestinationContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(destinationContents, expectedDestinationContents);

          final expectedOriginContents = <String>[
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

          final originContents = await _getDestinationContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(originContents, expectedOriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Move just files from one repo to another repo root',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        final repoInfoHash = await originRepo.infoHash;

        //Select files, subfolders selected if contains files to move
        {
          await originRepoCubit.startEntriesSelection();

          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/file1.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/folder2/file6.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/folder2/file7.txt', size: 0),
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 5 selected: /folder1, /folder1/file1.txt, /folder1/folder2, /folder1/folder2/file6,7.txt
          expect(selectedEntries, hasLength(5));

          // Expect selected: /folder1, /folder1/file1.txt, /folder1/folder2, /folder1/folder2/file6,7.txt
          final expectedFolder1SelectedAll =
              <String, ({bool isDir, bool selected, bool? tristate})>{
            '/folder1': (isDir: true, selected: false, tristate: null),
            '/folder1/file1.txt': (
              isDir: false,
              selected: true,
              tristate: true
            ),
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

          expect(selectedEntries, equals(expectedFolder1SelectedAll));
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

          final destinationContents = await _getDestinationContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          final expectedDestinationContents = <String>[
            '/file1.txt',
            '/folder2',
            '/folder2/file6.txt',
            '/folder2/file7.txt',
          ];
          expect(destinationContents, expectedDestinationContents);

          final originContents = await _getDestinationContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          final expectedOriginContents = <String>[
            '/folder1',
            '/folder1/file0.txt',
            '/folder1/file2.txt',
            '/folder1/file3.txt',
            '/folder1/folder2',
            '/folder1/folder2/file4.txt',
            '/folder1/folder2/file5.txt',
          ];
          expect(originContents, expectedOriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Add extra entries and move just one file from one repo to another repo',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        final repoInfoHash = await originRepo.infoHash;

        //Add one extra folder, /folder1/folder2/folder3, 2 files to new folder
        {
          await Directory.create(originRepo, 'folder1/folder2/folder3');

          for (var i = 0; i < 2; i++) {
            final filePath = p.join(
              'folder1',
              'folder2',
              'folder3',
              'file$i.txt',
            );
            final file = await File.create(originRepo, filePath);
            await file.write(0, utf8.encode("123$i"));
            await file.close();
          }
        }

        //Select folder1 selects all its contents
        {
          await originRepoCubit.startEntriesSelection();

          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/folder2/folder3/file0.txt', size: 0),
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 4 selected: /folder1, /folder1/folder2/, /folder1/folder2/folder3, /folder1/folder2/folder3/file0.txt
          expect(selectedEntries, hasLength(4));

          // Expect selected: /folder1, /folder1/folder2, /folder1/folder2/folder3, /folder1/folder2/folder3/file0.txt
          final expectedFolder1SelectedAll =
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

          expect(selectedEntries, equals(expectedFolder1SelectedAll));
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

          final destinationContents = await _getDestinationContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          final expectedDestinationContents = <String>['/file0.txt'];
          expect(destinationContents, expectedDestinationContents);

          final expectedOriginContents = <String>[
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

          final originContents = await _getDestinationContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(originContents, expectedOriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Add extra entries and move from one repo to another repo',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        final repoInfoHash = await originRepo.infoHash;

        //Add one extra folder, /folder1/folder3, add 2 files to new folder
        {
          await Directory.create(originRepo, 'folder1/folder3');

          for (var i = 0; i < 2; i++) {
            final filePath = p.join('folder1', 'folder3', 'file$i.txt');
            final file = await File.create(originRepo, filePath);
            await file.write(0, utf8.encode("123$i"));
            await file.close();
          }
        }

        //Select individual files, select folder3/ selects all its contents
        {
          await originRepoCubit.startEntriesSelection();

          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/file1.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/file3.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/folder2/file4.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/folder2/file5.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/folder2/file6.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            FileEntry(path: '/folder1/folder2/file7.txt', size: 0),
          );
          await originRepoCubit.entrySelectionCubit.selectEntry(
            repoInfoHash,
            DirectoryEntry(path: '/folder1/folder3'),
          );

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 11 selected: /folder1, /folder1/file1,3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt, folder1/folder3, folder1/folder3/file0,1.txt
          expect(selectedEntries, hasLength(11));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          final expectedFolder1SelectedAll =
              <String, ({bool isDir, bool selected, bool? tristate})>{
            '/folder1': (isDir: true, selected: false, tristate: null),
            '/folder1/folder2': (isDir: true, selected: false, tristate: true),
            '/folder1/folder3': (isDir: true, selected: true, tristate: true),
            '/folder1/file1.txt': (
              isDir: false,
              selected: true,
              tristate: true
            ),
            '/folder1/file3.txt': (
              isDir: false,
              selected: true,
              tristate: true
            ),
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

          expect(selectedEntries, equals(expectedFolder1SelectedAll));
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

          final destinationContents = await _getDestinationContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          final expectedDestinationContents = <String>[
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
          expect(destinationContents, expectedDestinationContents);

          final expectedOriginContents = <String>[
            '/folder1',
            '/folder1/file0.txt',
            '/folder1/file2.txt',
            '/folder1/folder2',
          ];

          final originContents = await _getDestinationContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(originContents, expectedOriginContents);
        }
      },
    ),
  );
}

Future<List<FileSystemEntry>> _getDestinationContents(
  RepoCubit cubit,
  String path,
  List<FileSystemEntry> entries,
) async {
  final contents = await cubit.getFolderContents(path);
  for (var c in contents) {
    entries.add(c);
    if (c is DirectoryEntry) {
      await _getDestinationContents(cubit, c.path, entries);
    }
  }

  return entries;
}
