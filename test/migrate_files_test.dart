import 'dart:io';

import 'package:test/test.dart';
import 'package:ouisync_app/app/utils/files.dart';
import 'package:path/path.dart' hide equals;

// Run with `flutter test test/settings_test.dart`.
void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp();
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('migrateFiles sanity check', () async {
    final src = Directory(join(temp.path, 'src'));
    final dst = Directory(join(temp.path, 'dst'));

    await File(join(src.path, 'a.txt')).create(recursive: true);
    await File(join(src.path, 'dir/b.txt')).create(recursive: true);
    await Directory(join(src.path, 'empty')).create(recursive: true);
    await Link(join(src.path, 'inside-rel')).create('a.txt');
    await Link(join(src.path, 'inside-abs')).create(join(src.path, 'a.txt'));
    await Link(join(src.path, 'outside-rel')).create('../c.txt');
    await Link(join(src.path, 'outside-abs')).create(join(temp.path, 'c.txt'));

    await migrateFiles(src, dst);

    expect(
        await _collectFiles(dst),
        equals([
          ('a.txt', null),
          ('dir', null),
          ('dir/b.txt', null),
          ('empty', null),
          ('inside-abs', join(dst.path, 'a.txt')),
          ('inside-rel', 'a.txt'),
          ('outside-abs', join(temp.path, 'c.txt')),
          ('outside-rel', join(temp.path, 'c.txt')),
        ]));

    expect(await src.exists(), isFalse);
  });
}

Future<List<(String, String?)>> _collectFiles(
  Directory dir,
) async {
  final content = await dir
      .list(recursive: true, followLinks: false)
      .asyncMap(
        (e) async => (
          relative(e.path, from: dir.path),
          (e is Link) ? await e.target() : null
        ),
      )
      .toList();
  content.sort((a, b) => a.$1.compareTo(b.$1));

  return content;
}
