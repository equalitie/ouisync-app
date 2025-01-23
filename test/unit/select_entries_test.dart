import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync_app/app/models/folder.dart';
import 'package:ouisync_app/app/utils/utils.dart' show CacheServers, Mounter;
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as p;
import 'package:ouisync_app/app/cubits/cubits.dart'
    show EntryBottomSheetCubit, EntrySelectionCubit, NavigationCubit, RepoCubit;
import 'package:ouisync_app/app/models/models.dart' show RepoLocation;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'move_entry_between_repos_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late Repository repo;

  late RepoCubit repoCubit;

  late NativeChannels nativeChannels;
  late NavigationCubit navigationCubit;
  late EntrySelectionCubit entrySelectionCubit;
  late EntryBottomSheetCubit bottomSheetCubit;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    final locationOrigin =
        RepoLocation.fromDbPath(p.join(dir.path, "store.db"));

    session = Session.create(configPath: dir.path, kind: SessionKind.unique);

    repo = await Repository.create(
      session,
      store: locationOrigin.path,
      readSecret: null,
      writeSecret: null,
    );

    PathProviderPlatform.instance = FakePathProviderPlatform(dir);
    nativeChannels = FakeNativeChannels(session);

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    navigationCubit = NavigationCubit();
    entrySelectionCubit = EntrySelectionCubit();
    bottomSheetCubit = EntryBottomSheetCubit();

    final mounter = Mounter(session);

    repoCubit = await RepoCubit.create(
      nativeChannels: nativeChannels,
      repo: repo,
      session: session,
      location: locationOrigin,
      navigation: navigationCubit,
      entrySelection: entrySelectionCubit,
      bottomSheet: bottomSheetCubit,
      cacheServers: CacheServers.disabled,
      mounter: mounter,
    );

    // Create 1 nested folder
    {
      await Directory.create(repo, '/folder1');
    }

    // Create files
    {
      final file1 = await File.create(repo, '/file1.txt');
      await file1.write(0, utf8.encode("123"));
      await file1.close();

      final folder1file2 = await File.create(repo, '/folder1/file2.txt');
      await folder1file2.write(0, utf8.encode("123"));
      await folder1file2.close();

      final rootContents = await Directory.open(repo, '/');
      expect(rootContents, hasLength(2));

      final folder1Contents = await Directory.open(repo, 'folder1');
      expect(folder1Contents, hasLength(1));
    }
  });

  tearDown(() async {
    await repo.close();
    await session.close();
  });

  test('Only entries with the same parent are selected', () async {
    final repoInfoHash = await repo.infoHash;

    final file1 = FileEntry(path: '/file1.txt', size: 0);
    final file5 = FileEntry(path: '/folder1/file2.txt', size: 0);

    // Select file in folder1 & folder2, only select files in folder1

    await repoCubit.startEntriesSelection();

    await repoCubit.entrySelectionCubit.selectEntry(repoInfoHash, file1);
    await repoCubit.entrySelectionCubit.selectEntry(repoInfoHash, file5);

    final selectedEntries = repoCubit.entrySelectionCubit.entries;

    // Expect 1 selected: /file1.txt
    expect(selectedEntries, hasLength(1));

    // Expect selected: /file1.txt: false
    expect(selectedEntries, equals([file1]));

    await repoCubit.entrySelectionCubit.endSelection();

    final noSelectedEntries = repoCubit.entrySelectionCubit.entries.length;
    expect(noSelectedEntries, equals(0));
  });

  test('Select an entry before starting selection does nothing', () async {
    final repoInfoHash = await repo.infoHash;

    final file1 = FileEntry(path: '/file1.txt', size: 0);

    // Try to select entries without starting selection in the repoCubit
    // does not select any entry

    await repoCubit.entrySelectionCubit.selectEntry(repoInfoHash, file1);

    final selectedEntries = repoCubit.entrySelectionCubit.entries;

    // Expect 0 selected
    expect(selectedEntries, hasLength(0));
  });
}
