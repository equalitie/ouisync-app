import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late Repository pluginRepo;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    final location = RepoLocation.fromDbPath(p.join(dir.path, "store.db"));
    session = await Session.create(configPath: dir.path);

    pluginRepo = await Repository.create(
      session,
      path: location.path,
      readSecret: null,
      writeSecret: null,
    );
  });

  tearDown(() async {
    await pluginRepo.close();
    await session.close();
  });

  test('Move file (file1.txt) from root (/) to folder1 (/folder1)', () async {
    // Create on folder and one file in the root
    {
      await Directory.create(pluginRepo, '/folder1');

      final file = await File.create(pluginRepo, '/file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final rootContents = await Directory.read(pluginRepo, '/');
      expect(rootContents, hasLength(2));

      final expectedRoot = <DirEntry>[
        DirEntry('file1.txt', EntryType.file),
        DirEntry('folder1', EntryType.directory),
      ];
      expect(rootContents, dirEntryComparator(expectedRoot));
    }

    // Move file (/file1.txt) to folder (/folder2/file1.txt)
    {
      await pluginRepo.moveEntry('/file1.txt', '/folder1/file1.txt');

      final rootContents = await Directory.read(pluginRepo, '/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await Directory.read(pluginRepo, '/folder1');
      expect(folder1Contents, hasLength(1));

      final expectedFolder1Contents = <DirEntry>[
        DirEntry('file1.txt', EntryType.file)
      ];
      expect(folder1Contents, dirEntryComparator(expectedFolder1Contents));
    }
  });

  test('Move folder ok when folder to move is empty', () async {
    // Create two empty folders
    {
      await Directory.create(pluginRepo, '/folder1');
      await Directory.create(pluginRepo, '/folder2');

      final rootContents = await Directory.read(pluginRepo, '/');
      expect(rootContents, hasLength(2));

      final expectedRoot = <DirEntry>[
        DirEntry('folder1', EntryType.directory),
        DirEntry('folder2', EntryType.directory),
      ];
      expect(rootContents, dirEntryComparator(expectedRoot));
    }

    // Move empty folder to other repo
    {
      await pluginRepo.moveEntry('/folder2', '/folder1/folder2');

      final rootContents = await Directory.read(pluginRepo, '/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await Directory.read(pluginRepo, '/folder1');
      expect(folder1Contents, hasLength(1));

      final expectedFolder1Contents = <DirEntry>[
        DirEntry('folder2', EntryType.directory)
      ];
      expect(folder1Contents, dirEntryComparator(expectedFolder1Contents));
    }
  });

  test('Move folder ok when folder to move is not empty', () async {
    // Create two folders, with one file inside folder2
    {
      await Directory.create(pluginRepo, '/folder1');
      await Directory.create(pluginRepo, '/folder2');

      final file = await File.create(pluginRepo, '/folder2/file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final rootContents = await Directory.read(pluginRepo, '/');
      expect(rootContents, hasLength(2));

      final folder2Contents = await Directory.read(pluginRepo, '/folder2');
      expect(folder2Contents, hasLength(1));

      final expectedRoot = <DirEntry>[
        DirEntry('folder1', EntryType.directory),
        DirEntry('folder2', EntryType.directory),
      ];
      expect(rootContents, dirEntryComparator(expectedRoot));

      final expectedFolder2 = <DirEntry>[DirEntry('file1.txt', EntryType.file)];
      expect(folder2Contents, dirEntryComparator(expectedFolder2));
    }

    // Move folder2 (/folder2) to folder1 (/folder1/folder2) containing
    // file1.txt (/folder2/file1.txt)
    {
      await pluginRepo.moveEntry('/folder2', '/folder1/folder2');

      final rootContents = await Directory.read(pluginRepo, '/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await Directory.read(pluginRepo, '/folder1');
      expect(folder1Contents, hasLength(1));

      final expectedFolder1Contents = <DirEntry>[
        DirEntry('folder2', EntryType.directory)
      ];
      expect(folder1Contents, dirEntryComparator(expectedFolder1Contents));

      final folder2Contents = await Directory.read(pluginRepo, '/folder1/folder2');
      expect(folder2Contents, hasLength(1));

      final expectedFolder2 = <DirEntry>[DirEntry('file1.txt', EntryType.file)];
      expect(folder2Contents, dirEntryComparator(expectedFolder2));
    }
  });
}

Matcher dirEntryComparator(Iterable<DirEntry> expected) => pairwiseCompare(
      expected,
      (DirEntry e0, DirEntry? e1) =>
          e0.entryType == e1?.entryType && e0.name == e1?.name,
      'Check for same DirEntry',
    );
