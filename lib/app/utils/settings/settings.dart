import 'dart:io' as io;

import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'v1.dart' as v1;
import '../files.dart';
import '../log.dart';
import '../master_key.dart';

typedef DatabaseId = v1.DatabaseId;
typedef Settings = v1.Settings;

Future<Settings> loadAndMigrateSettings(Session session) async {
  await _migratePaths();

  final prefs = await SharedPreferences.getInstance();
  final masterKey = await MasterKey.init();

  return await v1.Settings.init(prefs, masterKey, session);
}

Future<void> _migratePaths() async {
  final newDir = await getApplicationSupportDirectory();
  final oldDir = io.Directory(newDir.path
      .split(separator)
      .map((component) => (component == 'ouisync') ? 'ouisync_app' : component)
      .join(separator));

  if (newDir.path != oldDir.path && await oldDir.exists()) {
    staticLogger<Settings>().info(
      'migrating app support directory ${oldDir.path} -> ${newDir.path}',
    );

    await migrateFiles(oldDir, newDir);
  }
}
