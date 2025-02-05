import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/cubits.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync/ouisync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as repo_path;

import '../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDependencies deps;

  late ReposCubit reposCubit;

  late Repository originRepo;
  late Repository destinationRepo;

  late RepoCubit originRepoCubit;

  late NavigationCubit navigationCubit;
  late EntrySelectionCubit entrySelectionCubit;
  late EntryBottomSheetCubit bottomSheetCubit;

  setUp(() async {
    deps = await TestDependencies.create();

    originRepo = await Repository.create(
      deps.session,
      path: 'origin',
      readSecret: null,
      writeSecret: null,
    );

    destinationRepo = await Repository.create(
      deps.session,
      path: 'destination',
      readSecret: null,
      writeSecret: null,
    );

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    navigationCubit = NavigationCubit();
    entrySelectionCubit = EntrySelectionCubit();
    bottomSheetCubit = EntryBottomSheetCubit();

    final cacheServers = CacheServers(deps.session);

    originRepoCubit = await RepoCubit.create(
      nativeChannels: deps.nativeChannels,
      repo: originRepo,
      navigation: navigationCubit,
      entrySelection: entrySelectionCubit,
      bottomSheet: bottomSheetCubit,
      cacheServers: cacheServers,
      session: deps.session,
    );

    reposCubit = ReposCubit(
      session: deps.session,
      nativeChannels: deps.nativeChannels,
      settings: deps.settings,
      cacheServers: cacheServers,
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

      final rootContents = await Directory.read(originRepo, '/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await Directory.read(
        originRepo,
        'folder1',
      );
      expect(folder1Contents, hasLength(5));

      final folder2Contents = await Directory.read(
        originRepo,
        'folder1/folder2',
      );
      expect(folder2Contents, hasLength(5));

      final folder3Contents = await Directory.read(
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

        // Navigate to /folder1,
        {
          await originRepoCubit.navigateTo('/folder1');

          final currentFolder = originRepoCubit.state.currentFolder;
          expect(currentFolder.path, equals('/folder1'));
        }

        // Start selection, then select /folder1/folder2/
        {
          await originRepoCubit.startEntriesSelection();

          final repoInfoHash = await originRepoCubit.infoHash;
          await entrySelectionCubit.selectEntry(
            repoInfoHash,
            DirectoryEntry(path: '/folder1/folder2/'),
          );
        }

        final moveEntriesActions = MoveEntriesActions(
          context,
          reposCubit: reposCubit,
          originRepoCubit: originRepoCubit,
          sheetType: BottomSheetType.move,
        );

        final validation = entrySelectionCubit.validateDestination;

        // Navigate to /folder1,
        {
          await originRepoCubit.navigateTo('/');

          final currentFolder = originRepoCubit.state.currentFolder;
          expect(currentFolder.path, equals('/'));
        }

        // Check moving /folder1/folder2/ to /
        {
          final currentRepo = reposCubit.state.current;
          final canMove = moveEntriesActions.enableAction(
            validation,
            currentRepo,
          );

          expect(canMove, equals(true));
        }
      },
    ),
  );
}
