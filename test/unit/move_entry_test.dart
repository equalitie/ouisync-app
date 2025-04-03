import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late Repository repo;

  setUp(() async {
    final dir = await io.Directory.systemTemp.createTemp();
    session = await Session.create(configPath: dir.path);

    repo = await session.createRepository(
      path: p.join(dir.path, 'repo'),
      readSecret: null,
      writeSecret: null,
    );
  });

  tearDown(() async {
    await repo.close();
    await session.close();
  });

  test('Move file (file1.txt) from root (/) to folder1 (/folder1)', () async {
    // Create on folder and one file in the root
    {
      await repo.createDirectory('/folder1');

      final file = await repo.createFile('/file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final rootContents = await repo.readDirectory('/');
      expect(rootContents, hasLength(2));

      final expectedRoot = <DirectoryEntry>[
        DirectoryEntry(name: 'file1.txt', entryType: EntryType.file),
        DirectoryEntry(name: 'folder1', entryType: EntryType.directory),
      ];
      expect(rootContents, dirEntryComparator(expectedRoot));
    }

    // Move file (/file1.txt) to folder (/folder2/file1.txt)
    {
      await repo.moveEntry('/file1.txt', '/folder1/file1.txt');

      final rootContents = await repo.readDirectory('/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await repo.readDirectory('/folder1');
      expect(folder1Contents, hasLength(1));

      final expectedFolder1Contents = <DirectoryEntry>[
        DirectoryEntry(name: 'file1.txt', entryType: EntryType.file)
      ];
      expect(folder1Contents, dirEntryComparator(expectedFolder1Contents));
    }
  });

  test('Move folder ok when folder to move is empty', () async {
    // Create two empty folders
    {
      await repo.createDirectory('/folder1');
      await repo.createDirectory('/folder2');

      final rootContents = await repo.readDirectory('/');
      expect(rootContents, hasLength(2));

      final expectedRoot = <DirectoryEntry>[
        DirectoryEntry(name: 'folder1', entryType: EntryType.directory),
        DirectoryEntry(name: 'folder2', entryType: EntryType.directory),
      ];
      expect(rootContents, dirEntryComparator(expectedRoot));
    }

    // Move empty folder to other repo
    {
      await repo.moveEntry('/folder2', '/folder1/folder2');

      final rootContents = await repo.readDirectory('/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await repo.readDirectory('/folder1');
      expect(folder1Contents, hasLength(1));

      final expectedFolder1Contents = <DirectoryEntry>[
        DirectoryEntry(name: 'folder2', entryType: EntryType.directory)
      ];
      expect(folder1Contents, dirEntryComparator(expectedFolder1Contents));
    }
  });

  test('Move folder ok when folder to move is not empty', () async {
    // Create two folders, with one file inside folder2
    {
      await repo.createDirectory('/folder1');
      await repo.createDirectory('/folder2');

      final file = await repo.createFile('/folder2/file1.txt');
      await file.write(0, utf8.encode("123"));
      await file.close();

      final rootContents = await repo.readDirectory('/');
      expect(rootContents, hasLength(2));

      final folder2Contents = await repo.readDirectory('/folder2');
      expect(folder2Contents, hasLength(1));

      final expectedRoot = <DirectoryEntry>[
        DirectoryEntry(name: 'folder1', entryType: EntryType.directory),
        DirectoryEntry(name: 'folder2', entryType: EntryType.directory),
      ];
      expect(rootContents, dirEntryComparator(expectedRoot));

      final expectedFolder2 = <DirectoryEntry>[
        DirectoryEntry(name: 'file1.txt', entryType: EntryType.file)
      ];
      expect(folder2Contents, dirEntryComparator(expectedFolder2));
    }

    // Move folder2 (/folder2) to folder1 (/folder1/folder2) containing
    // file1.txt (/folder2/file1.txt)
    {
      await repo.moveEntry('/folder2', '/folder1/folder2');

      final rootContents = await repo.readDirectory('/');
      expect(rootContents, hasLength(1));

      final folder1Contents = await repo.readDirectory('/folder1');
      expect(folder1Contents, hasLength(1));

      final expectedFolder1Contents = <DirectoryEntry>[
        DirectoryEntry(name: 'folder2', entryType: EntryType.directory)
      ];
      expect(folder1Contents, dirEntryComparator(expectedFolder1Contents));

      final folder2Contents = await repo.readDirectory('/folder1/folder2');
      expect(folder2Contents, hasLength(1));

      final expectedFolder2 = <DirectoryEntry>[
        DirectoryEntry(name: 'file1.txt', entryType: EntryType.file)
      ];
      expect(folder2Contents, dirEntryComparator(expectedFolder2));
    }
  });
}

Matcher dirEntryComparator(Iterable<DirectoryEntry> expected) =>
    pairwiseCompare(
      expected,
      (DirectoryEntry e0, DirectoryEntry? e1) =>
          e0.entryType == e1?.entryType && e0.name == e1?.name,
      'Check for same DirectoryEntry',
    );
