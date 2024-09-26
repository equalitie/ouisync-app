import 'dart:convert';
import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../files.dart';
import '../master_key.dart';
import '../utils.dart';
import 'atomic_shared_prefs_settings_key.dart';
import 'v1.dart' as v1;

typedef DatabaseId = v1.DatabaseId;

//--------------------------------------------------------------------

class SettingsRoot {
  static const int version = 2;

  static const _versionKey = 'version';
  static const _acceptedEqualitieValuesKey = 'acceptedEqualitieValues';
  static const _showOnboardingKey = 'showOnboarding';
  static const _enableSyncOnMobileInternetKey = 'enableSyncOnMobileInternet';
  static const _enableLocalDiscoveryKey = 'enableLocalDiscovery';
  static const _highestSeenProtocolNumberKey = 'highestSeenProtocolNumber';
  static const _defaultRepoKey = 'defaultRepo';
  static const _reposKey = 'repos';
  static const _defaultRepositoriesDirVersionKey =
      'defaultRepositoriesDirVersion';

  // Did the user accept the eQ values?
  bool acceptedEqualitieValues = false;
  // Show onboarding (will flip to false once shown).
  bool showOnboarding = true;
  bool enableSyncOnMobileInternet = false;
  bool enableLocalDiscovery = true;
  int? highestSeenProtocolNumber;
  // NOTE: In order to preserve plausible deniability, once the current repo is
  // locked in _AuthModeBlindOrManual, this value must be set to `null`.
  RepoLocation? defaultRepo;
  Map<DatabaseId, RepoLocation> repos = {};

  // Whenever we change the default repos path, increment this value and implement a migration.
  int defaultRepositoriesDirVersion = 1;

  SettingsRoot._();

  SettingsRoot({
    required this.acceptedEqualitieValues,
    required this.showOnboarding,
    required this.enableSyncOnMobileInternet,
    required this.enableLocalDiscovery,
    required this.highestSeenProtocolNumber,
    required this.defaultRepo,
    required this.repos,
    required this.defaultRepositoriesDirVersion,
  });

  Map<String, dynamic> toJson() {
    final r = {
      _versionKey: version,
      _acceptedEqualitieValuesKey: acceptedEqualitieValues,
      _showOnboardingKey: showOnboarding,
      _enableSyncOnMobileInternetKey: enableSyncOnMobileInternet,
      _enableLocalDiscoveryKey: enableLocalDiscovery,
      _highestSeenProtocolNumberKey: highestSeenProtocolNumber,
      _defaultRepoKey: defaultRepo?.path,
      _reposKey: <String, Object?>{
        for (var kv in repos.entries) kv.key.toString(): kv.value.path
      },
      _defaultRepositoriesDirVersionKey: defaultRepositoriesDirVersion,
    };
    return r;
  }

  factory SettingsRoot.fromJson(String? s) {
    if (s == null) {
      return SettingsRoot._();
    }

    final data = json.decode(s);

    int inputVersion = data[_versionKey];

    if (inputVersion != version) {
      throw InvalidSettingsVersion(inputVersion);
    }

    final repos = {
      for (var kv in data[_reposKey]!.entries)
        DatabaseId(kv.key): RepoLocation.fromDbPath(kv.value)
    };

    String? defaultRepo = data[_defaultRepoKey];

    return SettingsRoot(
      acceptedEqualitieValues: data[_acceptedEqualitieValuesKey]!,
      showOnboarding: data[_showOnboardingKey]!,
      enableSyncOnMobileInternet: data[_enableSyncOnMobileInternetKey]!,
      enableLocalDiscovery: data[_enableLocalDiscoveryKey]!,
      highestSeenProtocolNumber: data[_highestSeenProtocolNumberKey],
      defaultRepo: defaultRepo?.let((path) => RepoLocation.fromDbPath(path)),
      repos: repos,
      defaultRepositoriesDirVersion:
          data[_defaultRepositoriesDirVersionKey] ?? 0,
    );
  }
}

class Settings with AppLogger {
  final MasterKey masterKey;

  final SettingsRoot _root;
  final SharedPreferences _prefs;

  //------------------------------------------------------------------

  Settings._(this._root, this._prefs, this.masterKey);

  Future<void> _storeRoot() async {
    await _prefs.setString(
        atomicSharedPrefsSettingsKey, json.encode(_root.toJson()));
  }

  static Future<Settings> init(
    MasterKey masterKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(atomicSharedPrefsSettingsKey);

    // The `atomicSharedPrefsSettingsKey` was introduced in V1 where it's the
    // only key. The other condition is to ensure this is not a freshly
    // generated `SharedPreferences` instance.
    if (json == null && prefs.getKeys().length != 0) {
      throw InvalidSettingsVersion(0);
    }

    final root = SettingsRoot.fromJson(json);

    return Settings._(root, prefs, masterKey);
  }

  static Future<Settings> initWithV1(v1.Settings settingsV1) async {
    final v1 = settingsV1.getMigrationContext();

    final root = SettingsRoot(
      acceptedEqualitieValues: v1.acceptedEqualitieValues,
      showOnboarding: v1.showOnboarding,
      // This is one thing that changed from V1 to V2, by default it's now
      // `false`.
      enableSyncOnMobileInternet: false,
      // This is another thing that changed, the V1 did not have it.
      enableLocalDiscovery: true,
      highestSeenProtocolNumber: v1.highestSeenProtocolNumber,
      defaultRepo: v1.defaultRepo,
      repos: v1.repos,
      defaultRepositoriesDirVersion: v1.defaultRepositoriesDirVersion,
    );

    final settingsV2 = Settings._(root, v1.sharedPreferences, v1.masterKey);

    await settingsV2._storeRoot();

    return settingsV2;
  }

  //------------------------------------------------------------------

  bool getEqualitieValues() => _root.acceptedEqualitieValues;

  Future<void> setEqualitieValues(bool value) async {
    _root.acceptedEqualitieValues = value;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  bool getShowOnboarding() => _root.showOnboarding;

  Future<void> setShowOnboarding(bool value) async {
    _root.showOnboarding = value;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  bool getSyncOnMobileEnabled() => _root.enableSyncOnMobileInternet;

  Future<void> setSyncOnMobileEnabled(bool enable) async {
    _root.enableSyncOnMobileInternet = enable;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  bool getLocalDiscoveryEnabled() => _root.enableLocalDiscovery;

  Future<void> setLocalDiscoveryEnabled(bool enable) async {
    _root.enableLocalDiscovery = enable;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  int? getHighestSeenProtocolNumber() => _root.highestSeenProtocolNumber;

  Future<void> setHighestSeenProtocolNumber(int number) async {
    _root.highestSeenProtocolNumber = number;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  Iterable<RepoLocation> get repos => _root.repos.values;

  //------------------------------------------------------------------

  RepoLocation? getRepoLocation(DatabaseId repoId) => _root.repos[repoId];

  Future<void> setRepoLocation(DatabaseId repoId, RepoLocation location) async {
    _root.repos[repoId] = location;
    await _storeRoot();
  }

  DatabaseId? findRepoByLocation(RepoLocation location) => _root.repos.entries
      .where((entry) => entry.value == location)
      .map((entry) => entry.key)
      .firstOrNull;

  Future<void> renameRepo(
    DatabaseId repoId,
    RepoLocation newLocation,
  ) async {
    if (findRepoByLocation(newLocation) != null) {
      throw 'Failed to rename repo: "${newLocation.path}" already exists';
    }

    await setRepoLocation(repoId, newLocation);
  }

  //------------------------------------------------------------------

  RepoLocation? get defaultRepo => _root.defaultRepo;

  Future<void> setDefaultRepo(RepoLocation? location) async {
    if (location == _root.defaultRepo) return;
    _root.defaultRepo = location;

    await _storeRoot();
  }

  //------------------------------------------------------------------

  Future<void> forgetRepo(DatabaseId databaseId) async {
    final location = _root.repos.remove(databaseId);

    if (_root.defaultRepo == location) {
      _root.defaultRepo = null;
    }

    await _storeRoot();
  }

  //------------------------------------------------------------------
  Future<io.Directory> getDefaultRepositoriesDir() async {
    final baseDir =
        (io.Platform.isAndroid ? await getExternalStorageDirectory() : null) ??
            await getApplicationSupportDirectory();
    return io.Directory(join(baseDir.path, Constants.folderRepositoriesName));
  }

  //------------------------------------------------------------------

  void debugPrint() {
    print("============== Settings ===============");
    for (final kv in _root.repos.entries) {
      print("=== ${kv.key}");
    }
    print("=======================================");
  }
}

class InvalidSettingsVersion {
  int statedVersion;
  InvalidSettingsVersion(this.statedVersion);
  @override
  String toString() => "Invalid settings version ($statedVersion)";
}
