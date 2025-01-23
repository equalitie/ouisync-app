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

  late FileEntry file0;
  late FileEntry file1;
  late FileEntry file2;
  late FileEntry file3;
  late DirectoryEntry folder1;
  late FileEntry folder1file7;

  late List<FileSystemEntry> expectedAllSelected;
  late List<String> expectedAllContents;

  late List<FileSystemEntry> expectedFolder1File7Selected;
  late List<String> expectedFolder1File7Contents;
  late List<String> expectedFolder1File7OriginContents;

  late List<FileSystemEntry> expectedFolder1Selected;
  late List<String> expectedFolder1Contents;
  late List<String> expectedFolder1OriginContents;

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

    // Create 1 folder in originRepo
    {
      await Directory.create(originRepo, '/folder1');
    }

    // Create files and add to root, folder
    {
      for (var i = 0; i < 8; i++) {
        final path = i < 4 ? '/' : 'folder1';

        final filePath = repo_path.join(path, 'file$i.txt');
        final file = await File.create(originRepo, filePath);
        await file.write(0, utf8.encode("123$i"));
        await file.close();
      }

      final rootContents = await Directory.open(originRepo, '/');
      expect(rootContents, hasLength(5));

      final folder1Contents = await Directory.open(originRepo, 'folder1');
      expect(folder1Contents, hasLength(4));
    }

    // Prepare all the entries
    {
      file0 = FileEntry(path: '/file0.txt', size: 0);
      file1 = FileEntry(path: '/file1.txt', size: 0);
      file2 = FileEntry(path: '/file2.txt', size: 0);
      file3 = FileEntry(path: '/file3.txt', size: 0);
      folder1 = DirectoryEntry(path: '/folder1');
      folder1file7 = FileEntry(path: '/folder1/file7.txt', size: 0);
    }

    // Prepare expected contents
    {
      expectedAllSelected = [file0, file1, file2, file3, folder1];
      expectedAllContents = [
        '/file0.txt',
        '/file1.txt',
        '/file2.txt',
        '/file3.txt',
        '/folder1',
        '/folder1/file4.txt',
        '/folder1/file5.txt',
        '/folder1/file6.txt',
        '/folder1/file7.txt',
      ];

      expectedFolder1File7Selected = [folder1file7];
      expectedFolder1File7Contents = ['/file7.txt'];
      expectedFolder1File7OriginContents = [
        '/file0.txt',
        '/file1.txt',
        '/file2.txt',
        '/file3.txt',
        '/folder1',
        '/folder1/file4.txt',
        '/folder1/file5.txt',
        '/folder1/file6.txt',
      ];

      expectedFolder1Selected = [folder1];
      expectedFolder1Contents = [
        '/folder1',
        '/folder1/file4.txt',
        '/folder1/file5.txt',
        '/folder1/file6.txt',
        '/folder1/file7.txt',
      ];
      expectedFolder1OriginContents = [
        '/file0.txt',
        '/file1.txt',
        '/file2.txt',
        '/file3.txt',
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
    'Copy all entries from one repo root to another repo root',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        // All contents selected
        {
          await _selectEntries(
            originRepoCubit,
            [file0, file1, file2, file3, folder1],
          );

          final selectedEntries = originRepoCubit.entrySelectionCubit.entries;

          // Expect 5 selected
          expect(selectedEntries, hasLength(5));

          // Expect all selected: /file0-3.txt, /folder1
          expect(selectedEntries, equals(expectedAllSelected));
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
          expect(destinationContents, expectedAllContents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expectedAllContents);
        }
      },
    ),
  );

  testWidgets(
    'Move all entries from one repo root to another repo root, then copy them back',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        //Select all entries in root
        {
          await _selectEntries(
            originRepoCubit,
            [file0, file1, file2, file3, folder1],
          );

          final selectedEntries = originRepoCubit.entrySelectionCubit.entries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(5));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedAllSelected));
        }

        // Move all entries form origin root to destination root
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
          expect(destinationContents, expectedAllContents);

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
          await destinationRepoCubit.navigateTo('/');

          await _selectEntries(
            destinationRepoCubit,
            [file0, file1, file2, file3, folder1],
          );

          final selectedEntries =
              destinationRepoCubit.entrySelectionCubit.entries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(5));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedAllSelected));
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
          expect(destinationContents, expectedAllContents);

          final originContents = await _getPathContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in destination
          expect(originContents, expectedAllContents);
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

        // Select just /folder1/file7.txt
        {
          await originRepoCubit.navigateTo('/folder1');
          await _selectEntries(originRepoCubit, [folder1file7]);

          final selectedEntries = originRepoCubit.entrySelectionCubit.entries;

          // Expect 1 selected: /folder1/file7.txt
          expect(selectedEntries, hasLength(1));

          // Expect selected: /folder1/file7.txt
          expect(selectedEntries, equals(expectedFolder1File7Selected));
        }

        // Move just /folder1/file7.txt
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

          // Expect only file7.txt copied to destination root
          expect(destinationContents, expectedFolder1File7Contents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expectedAllContents);
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

        // Select just /folder1/file7.txt
        {
          await originRepoCubit.navigateTo('/folder1');
          await _selectEntries(originRepoCubit, [folder1file7]);

          final selectedEntries = originRepoCubit.entrySelectionCubit.entries;

          // Expect 1 selected: /folder1/file7.txt
          expect(selectedEntries, hasLength(1));

          // Expect selected: /folder1/file7.txt
          expect(selectedEntries, equals(expectedFolder1File7Selected));
        }

        // Move just /folder1/file7.txt
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

          // Expect only file7.txt moved to destination root
          expect(
            destinationContents,
            expectedFolder1File7Contents,
          );

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only /folder1/file7.txt removed from origin contents
          expect(originContents, expectedFolder1File7OriginContents);
        }
      },
    ),
  );

  testWidgets(
    'Copy one folder from one repo to another repo, all contents are copyed',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        // Select /folder1
        {
          await _selectEntries(originRepoCubit, [folder1]);

          final selectedEntries = originRepoCubit.entrySelectionCubit.entries;

          // Expect 1 selected: /folder1
          expect(selectedEntries, hasLength(1));

          // Expect selected: /folder1
          expect(selectedEntries, equals(expectedFolder1Selected));
        }

        // Move /folder1/ and its contents
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

          // Expect /folder1 and its contents copied to destination root
          expect(destinationContents, expectedFolder1Contents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect all the original contents still in origin
          expect(originContents, expectedAllContents);
        }
      },
    ),
  );

  testWidgets(
    'Move one folder from one repo to another repo, all contents are moved',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        // Select /folder1
        {
          await _selectEntries(originRepoCubit, [folder1]);

          final selectedEntries = originRepoCubit.entrySelectionCubit.entries;

          // Expect 1 selected: /folder1
          expect(selectedEntries, hasLength(1));

          // Expect selected: /folder1
          expect(selectedEntries, equals(expectedFolder1Selected));
        }

        // Move just /folder1/file7.txt
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

          // Expect only /folder1 and its contents moved to destination root
          expect(destinationContents, expectedFolder1Contents);

          final originContents = await _getPathContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());

          // Expect only /folder1 and its contents removed from origin contents
          expect(originContents, expectedFolder1OriginContents);
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
