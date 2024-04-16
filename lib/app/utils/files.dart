import 'dart:io';
import 'package:path/path.dart';

/// Recursively moves all files, directories and links from `oldDir` to `newDir`. For links it also
/// updates their targets if they pointed within `oldDir` to point within `newDir`.
Future<void> migrateFiles(
  Directory oldDir,
  Directory newDir,
) async {
  await for (final e in oldDir.list(recursive: true, followLinks: false)) {
    final newPath = _convert(e.path, oldDir, newDir);

    await Directory(dirname(newPath)).create(recursive: true);

    switch (e) {
      case File():
        await e.rename(newPath);
      case Directory():
        if (await e.list().isEmpty) {
          await e.rename(newPath);
        }
      case Link():
        final oldTarget = await e.target();
        String newTarget;

        if (isAbsolute(oldTarget)) {
          if (isWithin(oldDir.path, oldTarget)) {
            newTarget = _convert(oldTarget, oldDir, newDir);
          } else {
            newTarget = oldTarget;
          }
        } else {
          final oldAbsTarget = canonicalize(join(dirname(e.path), oldTarget));

          if (isWithin(oldDir.path, oldAbsTarget)) {
            final newAbsTarget = _convert(oldAbsTarget, oldDir, newDir);
            newTarget = relative(newAbsTarget, from: dirname(newPath));
          } else {
            newTarget = oldAbsTarget;
          }
        }

        await Link(newPath).create(newTarget);
        await e.delete();
    }
  }

  await _removeEmptyRecursive(oldDir);
}

String _convert(String path, Directory oldDir, Directory newDir) =>
    join(newDir.path, relative(path, from: oldDir.path));

Future<void> _removeEmptyRecursive(Directory dir) async {
  await for (final e in dir.list(recursive: false, followLinks: false)) {
    if (e is Directory) {
      await _removeEmptyRecursive(e);
    }
  }

  try {
    await dir.delete(recursive: false);
  } on FileSystemException {
    // Not empty, ignore.
  }
}
