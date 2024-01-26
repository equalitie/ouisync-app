import 'v0.dart' as v0;

import 'package:shared_preferences/shared_preferences.dart';

typedef SettingsRepoEntry = v0.SettingsRepoEntry;
typedef Settings = v0.Settings;

Future<Settings> loadAndMigrateSettings() async {
  final prefs = await SharedPreferences.getInstance();
  return Settings.init(prefs);
}
