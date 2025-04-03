import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/folder.dart';
import 'package:ouisync_app/app/utils/utils.dart' show CacheServers;
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/cubits/cubits.dart'
    show EntryBottomSheetCubit, EntrySelectionCubit, NavigationCubit, RepoCubit;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDependencies deps;
  late Repository repo;

  late RepoCubit repoCubit;

  late NavigationCubit navigationCubit;
  late EntrySelectionCubit entrySelectionCubit;
  late EntryBottomSheetCubit bottomSheetCubit;

  setUp(() async {
    deps = await TestDependencies.create();

    repo = await deps.session.createRepository(
      path: 'repo',
      readSecret: null,
      writeSecret: null,
    );

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    navigationCubit = NavigationCubit();
    entrySelectionCubit = EntrySelectionCubit();
    bottomSheetCubit = EntryBottomSheetCubit();

    repoCubit = await RepoCubit.create(
      nativeChannels: deps.nativeChannels,
      repo: repo,
      session: deps.session,
      navigation: navigationCubit,
      entrySelection: entrySelectionCubit,
      bottomSheet: bottomSheetCubit,
      cacheServers: CacheServers(deps.session),
    );

    // Create 1 nested folder
    {
      await repo.createDirectory('/folder1');
    }

    // Create files
    {
      final file1 = await repo.createFile('/file1.txt');
      await file1.write(0, utf8.encode("123"));
      await file1.close();

      final folder1file2 = await repo.createFile('/folder1/file2.txt');
      await folder1file2.write(0, utf8.encode("123"));
      await folder1file2.close();

      final rootContents = await repo.readDirectory('/');
      expect(rootContents, hasLength(2));

      final folder1Contents = await repo.readDirectory('folder1');
      expect(folder1Contents, hasLength(1));
    }
  });

  tearDown(() async {
    await repo.close();
    await deps.dispose();
  });

  test('Only entries with the same parent are selected', () async {
    final repoInfoHash = await repo.getInfoHash();

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
    final repoInfoHash = await repo.getInfoHash();

    final file1 = FileEntry(path: '/file1.txt', size: 0);

    // Try to select entries without starting selection in the repoCubit
    // does not select any entry

    await repoCubit.entrySelectionCubit.selectEntry(repoInfoHash, file1);

    final selectedEntries = repoCubit.entrySelectionCubit.entries;

    // Expect 0 selected
    expect(selectedEntries, hasLength(0));
  });
}
