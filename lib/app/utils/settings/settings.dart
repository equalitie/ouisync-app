import 'dart:io' as io;

import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'v1.dart' as v1;
import '../files.dart';
import '../log.dart';
import '../master_key.dart';

typedef DatabaseId = v1.DatabaseId;
typedef Settings = v1.Settings;

Future<Settings> loadAndMigrateSettings(Session session) async {
  await _migratePaths();

  final masterKey = await MasterKey.init();

  final settings = await v1.Settings.init(masterKey);
  await settings.migrate(session);

  return settings;
}

Future<void> _migratePaths() async {
  final newDir = await getApplicationSupportDirectory();
  final oldDir = io.Directory(newDir.path
      .split(separator)
      .map((component) => (component == 'ouisync') ? 'ouisync_app' : component)
      .join(separator));

  if (newDir.path == oldDir.path) {
    return;
  }

  if (!(await oldDir.exists())) {
    return;
  }

  final logger = staticLogger<Settings>();

  logger.info(
    'migrating app support directory ${oldDir.path} -> ${newDir.path}',
  );

  final statuses = await migrateFiles(oldDir, newDir);

  for (final status in statuses) {
    if (status.exception != null) {
      logger.error(
        'failed to move ${status.oldPath} -> ${status.newPath}:',
        status.exception,
      );
    }
  }
}
