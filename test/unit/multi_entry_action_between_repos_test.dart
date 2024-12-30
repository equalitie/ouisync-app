import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync_app/app/models/folder.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/utils.dart' show CacheServers, Mounter;
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as p;
import 'package:ouisync_app/app/cubits/cubits.dart'
    show EntryBottomSheetCubit, EntrySelectionCubit, NavigationCubit, RepoCubit;
import 'package:ouisync_app/app/models/models.dart' show RepoLocation;
import 'package:ouisync_app/generated/l10n.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';
import 'move_entry_between_repos_test.dart';
import 'multi_entry_action_between_repos_test.mocks.dart';

@GenerateNiceMocks([MockSpec<BuildContext>()])
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
        RepoLocation.fromDbPath(p.join(dir.path, "store1.db"));
    final locationDestination =
        RepoLocation.fromDbPath(p.join(dir.path, "store2.db"));

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

    // Create 2 nested folders in originRepo
    {
      await Directory.create(originRepo, '/folder1');
      await Directory.create(originRepo, 'folder1/folder2');
    }

    // Create files in originRepo
    {
      for (var i = 0; i < 8; i++) {
        final path = i < 4 ? 'folder1' : p.join('folder1', 'folder2');

        final filePath = p.join(path, 'file$i.txt');
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
    'Move entries from one repo to another repo',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        final repoInfoHash = await originRepo.infoHash;

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

        //Select folder1 selects all its contents
        {
          final dirEntry = DirectoryEntry(path: '/folder1');

          await originRepoCubit.startEntriesSelection();
          await originRepoCubit.entrySelectionCubit
              .selectEntry(repoInfoHash, dirEntry);

          final selectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;

          // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, hasLength(10));

          // Expect /folder1 selected: /folder1: true
          expect(selectedEntries.keys.first, equals('/folder1'));
          expect(selectedEntries.values.first.isDir, equals(true));
          expect(selectedEntries.values.first.selected, equals(true));
          expect(selectedEntries.values.first.tristate, equals(true));

          // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
          expect(selectedEntries, equals(expectedFolder1SelectedAll));

          // Move all selected entries form repo
          final result =
              await originRepoCubit.entrySelectionCubit.moveEntriesTo(
            context,
            destinationRepoCubit: destinationRepoCubit,
            destinationPath: '/',
          );
          expect(result, equals(true));

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

          final destinationContents = await _getDestinationContents(
            destinationRepoCubit,
            '/',
            <FileSystemEntry>[],
          ).then((value) => value.map((e) => e.path).toList());
          expect(destinationContents, expectedDestinationContents);

          final originContents = await _getDestinationContents(
            originRepoCubit,
            '/',
            <FileSystemEntry>[],
          );
          expect(originContents.isEmpty, equals(true));

          final noSelectedEntries =
              originRepoCubit.entrySelectionCubit.selectedEntries;
          expect(noSelectedEntries, hasLength(0));
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
