import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync_app/app/cubits/cubits.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:ouisync/ouisync.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as repo_path;

import '../utils.dart';
import 'move_entry_between_repos_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late TestDependencies deps;

  late ReposCubit reposCubit;

  late Repository originRepo;
  late Repository destinationRepo;

  late RepoCubit originRepoCubit;

  late NativeChannels nativeChannels;
  late Settings settings;
  late NavigationCubit navigationCubit;
  late EntrySelectionCubit entrySelectionCubit;
  late EntryBottomSheetCubit bottomSheetCubit;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    final locationOrigin = RepoLocation.fromDbPath(p.join(
      dir.path,
      "store.db",
    ));
    final locationDestination = RepoLocation.fromDbPath(p.join(
      dir.path,
      "store2.db",
    ));

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
    settings = await Settings.init(MasterKey.random());

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    navigationCubit = NavigationCubit();
    entrySelectionCubit = EntrySelectionCubit();
    bottomSheetCubit = EntryBottomSheetCubit();

    final mounter = Mounter(session);

    originRepoCubit = await RepoCubit.create(
      nativeChannels: nativeChannels,
      repo: originRepo,
      location: locationOrigin,
      navigation: navigationCubit,
      entrySelection: entrySelectionCubit,
      bottomSheet: bottomSheetCubit,
      cacheServers: CacheServers.disabled,
      mounter: mounter,
      session: session,
    );

    reposCubit = ReposCubit(
      session: session,
      nativeChannels: nativeChannels,
      settings: settings,
      cacheServers: CacheServers(Constants.cacheServers),
      mounter: mounter,
    );

    // Create 2 folders, 1 nested, in originRepo
    {
      await Directory.create(originRepo, '/folder1');
      await Directory.create(originRepo, 'folder1/folder2');
    }

    // Create files and add to folders
    {
      for (var i = 0; i < 12; i++) {
        final path = i < 4
            ? 'folder1'
            : i < 8
                ? repo_path.join('folder1', 'folder2')
                : repo_path.join('folder1', 'folder2', 'folder3');

        final filePath = repo_path.join(path, 'file$i.txt');
        final file = await File.create(originRepo, filePath);
        await file.write(0, utf8.encode("123$i"));
        await file.close();
      }

      final rootContents = await Directory.open(originRepo, '/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await Directory.open(
        originRepo,
        'folder1',
      );
      expect(folder1Contents, hasLength(5));

      final folder2Contents = await Directory.open(
        originRepo,
        'folder1/folder2',
      );
      expect(folder2Contents, hasLength(5));

      final folder3Contents = await Directory.open(
        originRepo,
        'folder1/folder2/folder3',
      );
      expect(folder3Contents, hasLength(4));
    }
  });

  tearDown(() async {
    await destinationRepo.close();
    await originRepo.close();

    await deps.dispose();
    await session.close();
  });

  testWidgets(
    'Check if an entry can be moved to the destination path',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(find.byType(MainPage));

        // Set originRepoCubit as current repo
        {
          final originRepoEntry = OpenRepoEntry(originRepoCubit);
          await reposCubit.setCurrent(originRepoEntry);
          await tester.pumpAndSettle();
        }

        final moveEntriesActions = MoveEntriesActions(
          context,
          reposCubit: reposCubit,
          originRepoCubit: originRepoCubit,
          sheetType: BottomSheetType.move,
        );

        final entry = DirectoryEntry(path: '/folder1/folder2/');
        // Check moving /folder1/folder2/ to /
        {
          final canMove = moveEntriesActions.canMove(
            entry: entry,
            destinationPath: '/',
            destinationRepoLocation: originRepoCubit.location,
            isCurrentRepoWriteMode: true,
          );

          expect(canMove, equals(true));
        }

        // Check moving /folder1/folder2 to /folder1/folder2/folder3
        {
          final canMove = moveEntriesActions.canMove(
            entry: entry,
            destinationPath: '/folder1/folder2/folder3',
            destinationRepoLocation: originRepoCubit.location,
            isCurrentRepoWriteMode: true,
          );

          expect(canMove, equals(false));
        }
        {}
      },
    ),
  );
}
