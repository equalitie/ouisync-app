import 'v0/v0.dart' as v0;
import 'v1.dart' as v1;

import 'package:shared_preferences/shared_preferences.dart';

const String SETTINGS_VERSION_KEY = 'SETTINGS_VERSION';

typedef DatabaseId = v1.DatabaseId;
typedef RepoSettings = v1.RepoSettings;
typedef Settings = v1.Settings;
typedef AuthMode = v0.AuthMode;

Future<Settings> loadAndMigrateSettings() async {
  final prefs = await SharedPreferences.getInstance();
  var version = prefs.getInt(SETTINGS_VERSION_KEY) ?? 0;

  switch (version) {
    case 0:
      return await v1.Settings.initMigrateFromV0(prefs);
    case 1:
      return await v1.Settings.init(prefs);
    default:
      throw "Invalid settings version number $version";
  }
}
