import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/cubits.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDependencies deps;
  late Repository originRepo;
  late Repository otherRepo;

  late RepoCubit originRepoCubit;
  late RepoCubit otherRepoCubit;

  late NavigationCubit navigationCubit;
  late EntrySelectionCubit entrySelectionCubit;
  late EntryBottomSheetCubit bottomSheetCubit;

  setUp(() async {
    deps = await TestDependencies.create();

    originRepo = await deps.session.createRepository(
      path: 'origin',
      readSecret: null,
      writeSecret: null,
    );

    otherRepo = await deps.session.createRepository(
      path: 'other',
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

    otherRepoCubit = await RepoCubit.create(
      nativeChannels: deps.nativeChannels,
      repo: otherRepo,
      navigation: navigationCubit,
      entrySelection: entrySelectionCubit,
      bottomSheet: bottomSheetCubit,
      cacheServers: cacheServers,
      session: deps.session,
    );
  });

  tearDown(() async {
    await deps.dispose();
  });

  test('Move file to other repo', () async {
    final expectedFile1 = <DirectoryEntry>[
      DirectoryEntry(name: 'file1.txt', entryType: EntryType.file),
    ];

    // Create file to move
    {
      final file = await originRepo.createFile('file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final originContents = await originRepo.readDirectory('/');
      expect(originContents, hasLength(1));
      expect(originContents, dirEntryComparator(expectedFile1));
    }

    // Move file to other repo
    {
      final result = await originRepoCubit.moveEntryToRepo(
        destinationRepoCubit: otherRepoCubit,
        type: EntryType.file,
        source: '/file1.txt',
        destination: 'file1.txt',
        recursive: true,
      );

      expect(result, equals(true));

      final originContentsPost = await originRepo.readDirectory('/');
      final otherContents = await otherRepo.readDirectory('/');
      expect(originContentsPost, hasLength(0));

      expect(otherContents, hasLength(1));
      expect(otherContents, dirEntryComparator(expectedFile1));
    }
  });

  test('Move empty folder to other repo', () async {
    final expectedFolder1 = <DirectoryEntry>[
      DirectoryEntry(name: 'folder1', entryType: EntryType.directory)
    ];

    // Create empty folder to move
    {
      await originRepo.createDirectory('/folder1');

      final originContents = await originRepo.readDirectory('/');
      expect(originContents, hasLength(1));
      expect(originContents, dirEntryComparator(expectedFolder1));
    }

    // Move empty folder to other repo
    {
      final result = await originRepoCubit.moveEntryToRepo(
        destinationRepoCubit: otherRepoCubit,
        type: EntryType.directory,
        source: '/folder1',
        destination: '/folder1',
        recursive: true,
      );

      expect(result, equals(true));

      final originContentsPost = await originRepo.readDirectory('/');
      final otherContents = await otherRepo.readDirectory('/');
      expect(originContentsPost, hasLength(0));

      expect(otherContents, hasLength(1));
      expect(otherContents, dirEntryComparator(expectedFolder1));
    }
  });

  test('Move folder with one file to other repo', () async {
    final expectedFile1 = [
      DirectoryEntry(name: 'file1.txt', entryType: EntryType.file)
    ];
    // Create folder with one file to move
    {
      await originRepo.createDirectory('/folder1');

      final file = await originRepo.createFile('/folder1/file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final originContents = await originRepo.readDirectory('/');
      expect(originContents, hasLength(1));

      final folder1Contents = await originRepo.readDirectory('/folder1');
      expect(folder1Contents, hasLength(1));
      expect(folder1Contents, dirEntryComparator(expectedFile1));
    }

    // Move folder worth one file to other repo
    {
      final result = await originRepoCubit.moveEntryToRepo(
          destinationRepoCubit: otherRepoCubit,
          type: EntryType.directory,
          source: '/folder1',
          destination: '/folder1',
          recursive: true);

      expect(result, equals(true));

      final originContentsPost = await originRepo.readDirectory('/');
      final otherContents = await otherRepo.readDirectory('/');
      expect(originContentsPost, hasLength(0));

      final expectedFolder1 = [
        DirectoryEntry(name: 'folder1', entryType: EntryType.directory)
      ];
      expect(otherContents, hasLength(1));
      expect(otherContents, dirEntryComparator(expectedFolder1));

      final otherFolder1Contents = await otherRepo.readDirectory('/folder1');
      expect(otherFolder1Contents, hasLength(1));
      expect(otherFolder1Contents, dirEntryComparator(expectedFile1));
    }
  });

  // test('Move multiple folders with files to different repo', () async {
  //   late final originContents;
  //   // Create origin entries
  //   {
  //     await Directory.create(originRepo, 'folder1');
  //     await Directory.create(originRepo, 'folder1/folder2');
  //     await Directory.create(originRepo, 'folder1/folder3');
  //     await Directory.create(originRepo, 'folder1/folder3/folder4');

  //     await File.create(originRepo, 'folder1/file1.txt');
  //     await File.create(originRepo, 'folder1/file2.txt');
  //     await File.create(originRepo, 'folder1/folder2/folder4/file3.txt');

  //     originContents = await Directory.open(originRepo, '/');
  //   }

  //   // Move folder to other repo
  //   {
  //     final folder3ContentsPre = await Directory.open(
  //       originRepo,
  //       '/folder1/folder3',
  //     );

  //     final result = await originRepoCubit.moveEntryToRepo(
  //         destinationRepoCubit: otherRepoCubit,
  //         type: EntryType.directory,
  //         source: 'folder1/folder3',
  //         destination: 'folder3');

  //     expect(result, equals(true));
  //   }
  // });
}

Matcher dirEntryComparator(Iterable<DirectoryEntry> expected) =>
    pairwiseCompare(
      expected,
      (DirectoryEntry e0, DirectoryEntry? e1) =>
          e0.entryType == e1?.entryType && e0.name == e1?.name,
      'Check for same DirEntry',
    );

class FakeNativeChannels extends NativeChannels {
  FakeNativeChannels();
}

class FakePathProviderPlatform extends PathProviderPlatform {
  final io.Directory root;

  FakePathProviderPlatform(this.root);

  @override
  Future<String?> getApplicationSupportPath() async =>
      p.join(root.path, 'application-support');

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      p.join(root.path, 'application-documents');
}
