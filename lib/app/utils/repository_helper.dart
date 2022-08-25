import 'dart:io' as io;
import 'package:ouisync_app/app/utils/loggers/ouisync_app_logger.dart';
import 'package:path/path.dart' as p;

import 'utils.dart';

class RepositoryHelper {
  static final loggyInstance = OuiSyncAppLogger();

  static Future<bool> deleteRepositoryFiles(String repositoriesDir, {
    required String repositoryName
  }) async {
    if (!io.Directory(repositoriesDir).existsSync()) {
      return false;
    }

    final repositoryFiles = [
      p.join(repositoriesDir, '$repositoryName.db'),
      p.join(repositoriesDir, '$repositoryName.db-wal'),
      p.join(repositoriesDir, '$repositoryName.db-shm'),
    ];

    try {
      io.Directory(repositoriesDir)
      .listSync()
      .where((element) => repositoryFiles.contains(element.path))
      .forEach((element) {
        final path = element.path;
        element.deleteSync();

        loggyInstance.loggy.app('File deleted: $path');
      });
    } catch (e, st) {
      loggyInstance.loggy.app('Exception when deleting repo $repositoryName files', e, st);
      return false;
    }

    return true;
  }
}
