import 'dart:collection';

import 'v0.dart' as v0;
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
      final settingsV0 = await v0.Settings.init(prefs);
      return await _migrateV0toV1(prefs, settingsV0);
    case 1:
      return await v1.Settings.init(prefs);
    default:
      throw "Invalid settings version number $version";
  }
}

Future<Settings> _migrateV0toV1(prefs, v0.Settings settingsV0) async {
  final eqValues = settingsV0.getEqualitieValues();
  final showOnboarding = settingsV0.getShowOnboarding();
  final launchAtStartup = settingsV0.getLaunchAtStartup();
  final enableSyncOnMobileInternet = settingsV0.getSyncOnMobileEnabled();
  final highestSeenProtocolNumber = settingsV0.getHighestSeenProtocolNumber();
  final currentRepo = settingsV0.getDefaultRepo();

  final Map<DatabaseId, v1.SettingsRepoEntry> repos = HashMap();

  for (final repo in settingsV0.repos()) {
    final auth = settingsV0.getAuthenticationMode(repo.name);
    final id = DatabaseId(repo.databaseId);
    repos[id] = v1.SettingsRepoEntry(auth, repo.info);
  }

  final root = v1.SettingsRoot(
    acceptedEqualitieValues: eqValues,
    showOnboarding: showOnboarding,
    launchAtStartup: launchAtStartup,
    enableSyncOnMobileInternet: enableSyncOnMobileInternet,
    highestSeenProtocolNumber: highestSeenProtocolNumber,
    currentRepo: (currentRepo != null) ? DatabaseId(currentRepo) : null,
    repos: repos,
  );

  return await Settings.initFromMigration(root, prefs);
}
