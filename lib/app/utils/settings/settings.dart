import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'v1.dart' as v1;
import '../master_key.dart';

typedef DatabaseId = v1.DatabaseId;
typedef Settings = v1.Settings;

Future<Settings> loadAndMigrateSettings(Session session) async {
  final prefs = await SharedPreferences.getInstance();
  final masterKey = await MasterKey.init();

  return await v1.Settings.init(prefs, masterKey, session);
}
