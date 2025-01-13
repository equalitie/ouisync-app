import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/cubits.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late Repository originRepo;
  late Repository otherRepo;

  late RepoCubit originRepoCubit;
  late RepoCubit otherRepoCubit;

  late NativeChannels nativeChannels;
  late NavigationCubit navigationCubit;
  late EntryBottomSheetCubit bottomSheetCubit;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    final locationOrigin =
        RepoLocation.fromDbPath(p.join(dir.path, "store.db"));
    final locationOther =
        RepoLocation.fromDbPath(p.join(dir.path, "store2.db"));

    session = await Session.create(configPath: dir.path);

    originRepo = await Repository.create(
      session,
      path: locationOrigin.path,
      readSecret: null,
      writeSecret: null,
    );

    otherRepo = await Repository.create(
      session,
      path: locationOther.path,
      readSecret: null,
      writeSecret: null,
    );

    PathProviderPlatform.instance = FakePathProviderPlatform(dir);
    nativeChannels = NativeChannels();

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    navigationCubit = NavigationCubit();
    bottomSheetCubit = EntryBottomSheetCubit();

    originRepoCubit = await RepoCubit.create(
      nativeChannels: nativeChannels,
      repo: originRepo,
      location: locationOrigin,
      navigation: navigationCubit,
      bottomSheet: bottomSheetCubit,
      cacheServers: CacheServers.disabled,
      session: session,
    );

    otherRepoCubit = await RepoCubit.create(
      nativeChannels: nativeChannels,
      repo: otherRepo,
      location: locationOther,
      navigation: navigationCubit,
      bottomSheet: bottomSheetCubit,
      cacheServers: CacheServers.disabled,
      session: session,
    );
  });

  tearDown(() async {
    await otherRepo.close();
    await originRepo.close();
    await session.close();
  });

  test('Move file to other repo', () async {
    final expectedFile1 = <DirEntry>[DirEntry('file1.txt', EntryType.file)];

    // Create file to move
    {
      final file = await File.create(originRepo, 'file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final originContents = await Directory.read(originRepo, '/');
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
      );

      expect(result, equals(true));

      final originContentsPost = await Directory.read(originRepo, '/');
      final otherContents = await Directory.read(otherRepo, '/');
      expect(originContentsPost, hasLength(0));

      expect(otherContents, hasLength(1));
      expect(otherContents.entries, dirEntryComparator(expectedFile1));
    }
  });

  test('Move empty folder to other repo', () async {
    final expectedFolder1 = <DirEntry>[
      DirEntry('folder1', EntryType.directory)
    ];

    // Create empty folder to move
    {
      await Directory.create(originRepo, '/folder1');

      final originContents = await Directory.read(originRepo, '/');
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
      );

      expect(result, equals(true));

      final originContentsPost = await Directory.read(originRepo, '/');
      final otherContents = await Directory.read(otherRepo, '/');
      expect(originContentsPost, hasLength(0));

      expect(otherContents, hasLength(1));
      expect(otherContents.entries, dirEntryComparator(expectedFolder1));
    }
  });

  test('Move folder with one file to other repo', () async {
    final expectedFile1 = <DirEntry>[DirEntry('file1.txt', EntryType.file)];
    // Create folder with one file to move
    {
      await Directory.create(originRepo, '/folder1');

      final file = await File.create(originRepo, '/folder1/file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final originContents = await Directory.read(originRepo, '/');
      expect(originContents, hasLength(1));

      final folder1Contents = await Directory.read(originRepo, '/folder1');
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
      );

      expect(result, equals(true));

      final originContentsPost = await Directory.read(originRepo, '/');
      final otherContents = await Directory.read(otherRepo, '/');
      expect(originContentsPost, hasLength(0));

      final expectedFolder1 = <DirEntry>[
        DirEntry('folder1', EntryType.directory)
      ];
      expect(otherContents, hasLength(1));
      expect(otherContents.entries, dirEntryComparator(expectedFolder1));

      final otherFolder1Contents = await Directory.read(otherRepo, '/folder1');
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

Matcher dirEntryComparator(Iterable<DirEntry> expected) => pairwiseCompare(
      expected,
      (DirEntry e0, DirEntry? e1) =>
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
