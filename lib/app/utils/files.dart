import 'dart:io';
import 'package:path/path.dart';

/// Recursively moves all files, directories and links from `oldDir` to `newDir`. For links it also
/// updates their targets if they pointed within `oldDir` to point within `newDir`.
Future<List<MigrationStatus>> migrateFiles(
  Directory oldDir,
  Directory newDir,
) async {
  var statuses = <MigrationStatus>[];

  await for (final e in oldDir.list(recursive: true, followLinks: false)) {
    final newPath = _convertPath(e.path, oldDir, newDir);

    try {
      await Directory(dirname(newPath)).create(recursive: true);

      switch (e) {
        case File():
          await _moveFile(e, newPath);
        case Directory():
          if (await e.list().isEmpty) {
            await e.rename(newPath);
          }
        case Link():
          final oldTarget = await e.target();
          String newTarget;

          if (isAbsolute(oldTarget)) {
            if (isWithin(oldDir.path, oldTarget)) {
              newTarget = _convertPath(oldTarget, oldDir, newDir);
            } else {
              newTarget = oldTarget;
            }
          } else {
            final oldAbsTarget = canonicalize(join(dirname(e.path), oldTarget));

            if (isWithin(oldDir.path, oldAbsTarget)) {
              final newAbsTarget = _convertPath(oldAbsTarget, oldDir, newDir);
              newTarget = relative(newAbsTarget, from: dirname(newPath));
            } else {
              newTarget = oldAbsTarget;
            }
          }

          await Link(newPath).create(newTarget);
          await e.delete();
      }

      statuses.add(MigrationStatus(e.path, newPath));
    } on Exception catch (exception) {
      statuses.add(MigrationStatus(e.path, newPath, exception));
    }
  }

  await _removeEmptyRecursive(oldDir);

  return statuses;
}

class MigrationStatus {
  final String oldPath;
  final String newPath;
  final Exception? exception;

  MigrationStatus(this.oldPath, this.newPath, [this.exception]);
}

String _convertPath(String path, Directory oldDir, Directory newDir) =>
    join(newDir.path, relative(path, from: oldDir.path));

// Move file to dst. Unlike `File.rename` this also works across filesystems (by first making a
// copy and then deleting the original). Does not move if the destination already exists.
Future<void> _moveFile(File file, String dst) async {
  if (await File(dst).exists()) {
    // Don't overwrite files. This is important for example when a migration has already happened, but
    // the user for some reason again started some previous version of Ouisync app which created new
    // SharedPreferences. Then running the newer version of Ouisync app would perform the migration
    // again replacing the already migrated SharedPreferences with the newly created one.
    return;
  }

  try {
    await file.rename(dst);
  } on FileSystemException catch (_) {
    await file.copy(dst);
    await file.delete();
  }
}

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
