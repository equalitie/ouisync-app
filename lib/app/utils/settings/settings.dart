import 'dart:io' as io;

import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart';

import 'v1.dart' as v1;
import 'v2.dart' as v2;
import '../files.dart';
import '../log.dart' as log;
import '../master_key.dart';
import '../native.dart';

typedef DatabaseId = v2.DatabaseId;
typedef Settings = v2.Settings;
typedef SettingsLocale = v2.SettingsLocale;
typedef SettingsUserLocale = v2.SettingsUserLocale;
typedef SettingsDefaultLocale = v2.SettingsDefaultLocale;
typedef InvalidSettingsVersion = v2.InvalidSettingsVersion;

Future<Settings> loadAndMigrateSettings(Session session) async {
  await _migratePaths();

  final masterKey = await MasterKey.init();

  try {
    final settingsV2 = await v2.Settings.init(masterKey);
    return settingsV2;
  } on v2.InvalidSettingsVersion catch (e) {
    if (e.statedVersion < 2) {
      final settingsV1 = await v1.Settings.init(masterKey);
      await settingsV1.migrate(session);
      return await v2.Settings.initWithV1(settingsV1);
    } else {
      throw "Settings have been created with a newer Ouisync version and thus can't be migrated";
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> _migratePaths() async {
  final newDir = await Native.getBaseDir();
  final oldDir = io.Directory(
    newDir.path
        .split(separator)
        .map(
          (component) => (component == 'ouisync') ? 'ouisync_app' : component,
        )
        .join(separator),
  );

  if (newDir.path == oldDir.path) {
    return;
  }

  if (!(await oldDir.exists())) {
    return;
  }

  final logger = log.named('Settings');

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
