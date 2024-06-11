import 'dart:io' as io;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/cubits.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
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
  late Settings settings;
  late RepoLocation originLocation;
  late RepoLocation otherLocation;
  late NavigationCubit navigationCubit;
  late EntryBottomSheetCubit bottomSheetCubit;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    final locationOrigin =
        RepoLocation.fromDbPath(p.join(dir.path, "store.db"));
    final locationOther =
        RepoLocation.fromDbPath(p.join(dir.path, "store2.db"));

    session = Session.create(configPath: dir.path, kind: SessionKind.unique);

    originRepo = await Repository.create(
      session,
      store: locationOrigin.path,
      readSecret: null,
      writeSecret: null,
    );

    otherRepo = await Repository.create(
      session,
      store: locationOther.path,
      readSecret: null,
      writeSecret: null,
    );

    PathProviderPlatform.instance = FakePathProviderPlatform(dir);
    nativeChannels = FakeNativeChannels(session);

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final key = await MasterKey.init();
    settings = await Settings.init(sharedPreferences, key, session);
    originLocation = RepoLocation.fromDbPath(locationOrigin.path);
    otherLocation = RepoLocation.fromDbPath(locationOther.path);
    navigationCubit = NavigationCubit();
    bottomSheetCubit = EntryBottomSheetCubit();

    originRepoCubit = await RepoCubit.create(
      session: session,
      nativeChannels: nativeChannels,
      settings: settings,
      repo: originRepo,
      location: originLocation,
      navigation: navigationCubit,
      bottomSheet: bottomSheetCubit,
    );

    otherRepoCubit = await RepoCubit.create(
      session: session,
      nativeChannels: nativeChannels,
      settings: settings,
      repo: otherRepo,
      location: otherLocation,
      navigation: navigationCubit,
      bottomSheet: bottomSheetCubit,
    );
  });

  tearDown(() async {
    await otherRepo.close();
    await originRepo.close();
    await session.close();
  });

  test('Move file to other repo', () async {
    // Create file to move
    {
      await File.create(originRepo, 'file1.txt');

      final originContents = await Directory.open(originRepo, '/');
      expect(originContents, hasLength(1));
      expect(
        originContents,
        pairwiseCompare(
          <DirEntry>[DirEntry('file1.txt', EntryType.file)],
          (DirEntry e0, DirEntry? e1) {
            return e0.entryType == e1?.entryType && e0.name == e1?.name;
          },
          'Check for same DirEntry',
        ),
      );
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

      final originContentsPost = await Directory.open(originRepo, '/');
      final otherContents = await Directory.open(otherRepo, '/');
      expect(originContentsPost, hasLength(0));
      expect(otherContents, hasLength(1));

      expect(
        otherContents.entries,
        pairwiseCompare(
          <DirEntry>[DirEntry('file1.txt', EntryType.file)],
          (DirEntry e0, DirEntry? e1) {
            return e0.entryType == e1?.entryType && e0.name == e1?.name;
          },
          'Check for same DirEntry',
        ),
      );
    }
  });

  test('Move empty folder to other repo', () async {
    // Create empty folder to move
    {
      await Directory.create(originRepo, '/folder1');

      final originContents = await Directory.open(originRepo, '/');
      expect(originContents, hasLength(1));
      expect(
        originContents,
        pairwiseCompare(
          <DirEntry>[DirEntry('folder1', EntryType.directory)],
          (DirEntry e0, DirEntry? e1) {
            return e0.entryType == e1?.entryType && e0.name == e1?.name;
          },
          'Check for same DirEntry',
        ),
      );
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

      final originContentsPost = await Directory.open(originRepo, '/');
      final otherContents = await Directory.open(otherRepo, '/');
      expect(originContentsPost, hasLength(0));
      expect(otherContents, hasLength(1));

      expect(
        otherContents.entries,
        pairwiseCompare(
          <DirEntry>[DirEntry('folder1', EntryType.directory)],
          (DirEntry e0, DirEntry? e1) {
            return e0.entryType == e1?.entryType && e0.name == e1?.name;
          },
          'Check for same DirEntry',
        ),
      );
    }
  });

  test('Move folder with one file to other repo', () async {
    // Create folder with one file to move
    {
      await Directory.create(originRepo, '/folder1');
      await File.create(originRepo, '/folder1/file1.txt');

      final originContents = await Directory.open(originRepo, '/');
      expect(originContents, hasLength(1));

      final folder1Contents = await Directory.open(originRepo, '/folder1');
      expect(folder1Contents, hasLength(1));
      expect(
        folder1Contents,
        pairwiseCompare(
          <DirEntry>[DirEntry('file1.txt', EntryType.file)],
          (DirEntry e0, DirEntry? e1) {
            return e0.entryType == e1?.entryType && e0.name == e1?.name;
          },
          'Check for same DirEntry',
        ),
      );
    }

    // Move folder woth one file to other repo
    {
      final result = await originRepoCubit.moveEntryToRepo(
        destinationRepoCubit: otherRepoCubit,
        type: EntryType.directory,
        source: '/folder1',
        destination: '/folder1',
      );

      expect(result, equals(true));

      final originContentsPost = await Directory.open(originRepo, '/');
      final otherContents = await Directory.open(otherRepo, '/');
      expect(originContentsPost, hasLength(0));
      expect(otherContents, hasLength(1));
      expect(
        otherContents.entries,
        pairwiseCompare(
          <DirEntry>[DirEntry('folder1', EntryType.directory)],
          (DirEntry e0, DirEntry? e1) {
            return e0.entryType == e1?.entryType && e0.name == e1?.name;
          },
          'Check for same DirEntry',
        ),
      );

      final otherFolder1Contents = await Directory.open(otherRepo, '/folder1');
      expect(otherFolder1Contents, hasLength(1));
      expect(
        otherFolder1Contents,
        pairwiseCompare(
          <DirEntry>[DirEntry('file1.txt', EntryType.file)],
          (DirEntry e0, DirEntry? e1) {
            return e0.entryType == e1?.entryType && e0.name == e1?.name;
          },
          'Check for same DirEntry',
        ),
      );
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

class FakeNativeChannels extends NativeChannels {
  FakeNativeChannels(super.session);
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
