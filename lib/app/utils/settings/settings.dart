import 'v1.dart' as v1;
import '../master_key.dart';

import 'package:shared_preferences/shared_preferences.dart';

typedef DatabaseId = v1.DatabaseId;
typedef RepoSettings = v1.RepoSettings;
typedef Settings = v1.Settings;

Future<Settings> loadAndMigrateSettings() async {
  final prefs = await SharedPreferences.getInstance();
  var isVersionZero = !prefs.containsKey(v1.Settings.settingsKey);

  final masterKey = await MasterKey.init();

  if (isVersionZero) {
    return await v1.Settings.initMigrateFromV0(prefs, masterKey);
  } else {
    return await v1.Settings.init(prefs, masterKey);
  }
}
