import 'dart:io';

import 'package:test/test.dart';
import 'package:ouisync_app/app/utils/files.dart';
import 'package:path/path.dart' as p;

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
    final src = Directory(p.join(temp.path, 'src'));
    final dst = Directory(p.join(temp.path, 'dst'));

    await File(p.join(src.path, 'a.txt')).create(recursive: true);
    await File(p.join(src.path, 'dir/b.txt')).create(recursive: true);
    await Directory(p.join(src.path, 'empty')).create(recursive: true);
    await Link(p.join(src.path, 'inside-rel')).create('a.txt');
    await Link(
      p.join(src.path, 'inside-abs'),
    ).create(p.join(src.path, 'a.txt'));
    await Link(p.join(src.path, 'outside-rel')).create('../c.txt');
    await Link(
      p.join(src.path, 'outside-abs'),
    ).create(p.join(temp.path, 'c.txt'));

    await migrateFiles(src, dst);

    expect(
      await _collectContent(dst),
      equals([
        Entity('a.txt'),
        Entity('dir'),
        Entity(p.join('dir', 'b.txt')),
        Entity('empty'),
        Entity('inside-abs', p.join(dst.path, 'a.txt')),
        Entity('inside-rel', 'a.txt'),
        Entity('outside-abs', p.join(temp.path, 'c.txt')),
        Entity('outside-rel', p.join(temp.path, 'c.txt')),
      ]),
    );

    expect(await src.exists(), isFalse);
  });
}

class Entity {
  final String path;
  final String target;

  Entity(this.path, [this.target = '']);

  @override
  bool operator ==(Object other) =>
      other is Entity &&
      p.equals(path, other.path) &&
      p.equals(target, other.target);

  @override
  int get hashCode => p.hash(path) ^ p.hash(target);

  @override
  String toString() => target.isNotEmpty ? '$path -> $target' : path;
}

Future<List<Entity>> _collectContent(Directory dir) async {
  final content =
      await dir
          .list(recursive: true, followLinks: false)
          .asyncMap(
            (e) async => Entity(
              p.relative(e.path, from: dir.path),
              (e is Link) ? await e.target() : '',
            ),
          )
          .toList();
  content.sort((a, b) => a.path.compareTo(b.path));

  return content;
}
