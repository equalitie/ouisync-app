import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/folder.dart';
import 'package:ouisync_app/app/utils/utils.dart' show CacheServers;
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as p;
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

    repo = await Repository.create(
      deps.session,
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
      cacheServers: CacheServers.disabled,
    );

    // Create 2 nested folders
    {
      await Directory.create(repo, '/folder1');
      await Directory.create(repo, 'folder1/folder2');
    }

    // Create files
    {
      for (var i = 0; i < 8; i++) {
        final path = i < 4 ? 'folder1' : p.join('folder1', 'folder2');

        final filePath = p.join(path, 'file$i.txt');
        final file = await File.create(repo, filePath);
        await file.write(0, utf8.encode("123$i"));
        await file.close();
      }

      final rootContents = await Directory.read(repo, '/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await Directory.read(repo, 'folder1');
      expect(folder1Contents, hasLength(5));

      final folder2Contents = await Directory.read(repo, 'folder1/folder2');
      expect(folder2Contents, hasLength(4));
    }
  });

  tearDown(() async {
    await repo.close();
    await deps.dispose();
  });

  test(
      'Select a folder selects all children and update parents tristate selection',
      () async {
    final repoInfoHash = await repo.infoHash;

    final expectedFolder2SelectedAll =
        <String, ({bool isDir, bool selected, bool? tristate})>{
      '/folder1': (isDir: true, selected: false, tristate: null),
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

    // Select folder2 selects all its contents, and folder1 tristate
    {
      final dirEntry = DirectoryEntry(path: '/folder1/folder2');

      await repoCubit.startEntriesSelection();
      await repoCubit.entrySelectionCubit.selectEntry(repoInfoHash, dirEntry);

      final selectedEntries = repoCubit.entrySelectionCubit.selectedEntries;

      // Expect 6 selected: /folder1, /folder1/folder2, /folder1/folder2/files4-7.txt
      expect(selectedEntries, hasLength(6));

      // Expect /folder1 selected, tristate: /folder1: null
      expect(selectedEntries.keys.first, equals('/folder1'));
      expect(selectedEntries.values.first.isDir, equals(true));
      expect(selectedEntries.values.first.selected, equals(false));
      expect(selectedEntries.values.first.tristate, equals(null));

      // Expect selected: /folder1: null, /folder1/folder2: null, /folder1/folder2/files4-7.txt: false
      expect(selectedEntries, equals(expectedFolder2SelectedAll));

      await repoCubit.entrySelectionCubit.endSelection();

      final noSelectedEntries = repoCubit.entrySelectionCubit.selectedEntries;
      expect(noSelectedEntries, hasLength(0));
    }

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

      await repoCubit.startEntriesSelection();
      await repoCubit.entrySelectionCubit.selectEntry(repoInfoHash, dirEntry);

      final selectedEntries = repoCubit.entrySelectionCubit.selectedEntries;

      // Expect 10 selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
      expect(selectedEntries, hasLength(10));

      // Expect /folder1 selected: /folder1: true
      expect(selectedEntries.keys.first, equals('/folder1'));
      expect(selectedEntries.values.first.isDir, equals(true));
      expect(selectedEntries.values.first.selected, equals(true));
      expect(selectedEntries.values.first.tristate, equals(true));

      // Expect all selected: /folder1, /folder1/file0-3.txt, /folder1/folder2, /folder1/folder2/file4-7.txt
      expect(selectedEntries, equals(expectedFolder1SelectedAll));

      await repoCubit.entrySelectionCubit.endSelection();

      final noSelectedEntries = repoCubit.entrySelectionCubit.selectedEntries;
      expect(noSelectedEntries, hasLength(0));
    }
  });

  test('Select a children in a folder update parents tristate selection',
      () async {
    final repoInfoHash = await repo.infoHash;

    final expectedFolder2SelectedOneChild =
        <String, ({bool isDir, bool selected, bool? tristate})>{
      '/folder1': (isDir: true, selected: false, tristate: null),
      '/folder1/folder2': (isDir: true, selected: false, tristate: null),
      '/folder1/folder2/file6.txt': (
        isDir: false,
        selected: true,
        tristate: true
      )
    };

    // Select folder2 child updates folder1/folder2 and folder1, tristates
    {
      final fileEntry = FileEntry(path: '/folder1/folder2/file6.txt', size: 0);

      await repoCubit.startEntriesSelection();
      await repoCubit.entrySelectionCubit.selectEntry(repoInfoHash, fileEntry);

      final selectedEntries = repoCubit.entrySelectionCubit.selectedEntries;

      // Expect 3 selected: /folder1, /folder1/folder2, /folder1/folder2/file6.txt
      expect(selectedEntries, hasLength(3));

      // Expect /folder1 selected, tristate: /folder1: null
      expect(selectedEntries['/folder1']?.isDir, equals(true));
      expect(selectedEntries['/folder1']?.selected, equals(false));
      expect(selectedEntries['/folder1']?.tristate, equals(null));

      // Expect /folder1/folder2 selected, tristate: /folder1/folder2: null
      expect(selectedEntries['/folder1/folder2']?.isDir, equals(true));
      expect(selectedEntries['/folder1/folder2']?.selected, equals(false));
      expect(selectedEntries['/folder1/folder2']?.tristate, equals(null));

      // Expect selected: /folder1: null, /folder1/folder2: null, /folder1/folder2/file6.txt: false
      expect(selectedEntries, equals(expectedFolder2SelectedOneChild));
    }

    {
      final selectedEntries = repoCubit.entrySelectionCubit.selectedEntries;

      // Expect selected: /folder1: null, /folder1/folder2: null, /folder1/folder2/file6.txt: false
      expect(selectedEntries, equals(expectedFolder2SelectedOneChild));
    }

    {
      await repoCubit.entrySelectionCubit.endSelection();

      final noSelectedEntries = repoCubit.entrySelectionCubit.selectedEntries;
      expect(noSelectedEntries, hasLength(0));
    }
  });
}
