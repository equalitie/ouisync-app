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
import '../utils.dart';
import 'atomic_shared_prefs_settings_key.dart';
import 'v0/v0.dart' as v0;

class DatabaseId extends Equatable {
  final String _id;
  DatabaseId(String databaseId) : _id = databaseId;

  @override
  String toString() => _id;

  @override
  List<Object> get props => [_id];
}

//--------------------------------------------------------------------

class SettingsRoot {
  static const int version = 1;

  static const _versionKey = 'version';
  static const _acceptedEqualitieValuesKey = 'acceptedEqualitieValues';
  static const _showOnboardingKey = 'showOnboarding';
  static const _enableSyncOnMobileInternetKey = 'enableSyncOnMobileInternet';
  static const _highestSeenProtocolNumberKey = 'highestSeenProtocolNumber';
  static const _defaultRepoKey = 'defaultRepo';
  static const _reposKey = 'repos';
  static const _defaultRepositoriesDirVersionKey =
      'defaultRepositoriesDirVersion';

  // Did the user accept the eQ values?
  bool acceptedEqualitieValues = false;
  // Show onboarding (will flip to false once shown).
  bool showOnboarding = true;
  bool enableSyncOnMobileInternet = true;
  int? highestSeenProtocolNumber;
  // NOTE: In order to preserve plausible deniability, once the current repo is
  // locked in _AuthModeBlindOrManual, this value must set to `null`.
  RepoLocation? defaultRepo;
  Map<DatabaseId, RepoLocation> repos = {};

  // Whenever we change the default repos path, increment this value and implement a migration.
  int defaultRepositoriesDirVersion = 0;

  SettingsRoot._();

  SettingsRoot({
    required this.acceptedEqualitieValues,
    required this.showOnboarding,
    required this.enableSyncOnMobileInternet,
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
    final root = SettingsRoot.fromJson(json);

    return Settings._(root, prefs, masterKey);
  }

  Future<void> migrate(Session session) async {
    await _migrateValues(session);
    await _migrateRepositoryPaths();
  }

  Future<void> _migrateValues(Session session) async {
    // Check if already fully migrated. The `atomicSharedPrefsSettingsKey` was introduced in V1
    // where it's the only key.
    if (_prefs.containsKey(atomicSharedPrefsSettingsKey) &&
        _prefs.getKeys().length == 1) {
      return;
    }

    final s0 = await v0.Settings.init(_prefs);

    _root.acceptedEqualitieValues =
        s0.getEqualitieValues() ?? _root.acceptedEqualitieValues;
    _root.showOnboarding = s0.getShowOnboarding() ?? _root.showOnboarding;
    _root.enableSyncOnMobileInternet =
        s0.getSyncOnMobileEnabled() ?? _root.enableSyncOnMobileInternet;
    _root.highestSeenProtocolNumber =
        s0.getHighestSeenProtocolNumber() ?? _root.highestSeenProtocolNumber;
    _root.defaultRepo =
        s0.getDefaultRepo()?.let((name) => s0.repoLocation(name)) ??
            _root.defaultRepo;

    for (final repo in s0.repos()) {
      final databaseId = DatabaseId(repo.databaseId);
      final auth = s0.getAuthenticationMode(repo.name);

      AuthMode? authMode;
      v0.SecureStorage? oldPwdStorage;

      switch (auth) {
        case v0.AuthMode.manual:
          authMode = AuthModeBlindOrManual();
        case v0.AuthMode.version1:
        case v0.AuthMode.version2:
          oldPwdStorage = v0.SecureStorage(databaseId: databaseId);
          authMode = await _getNewAuthMode(
            oldPwdStorage,
            repo.name,
            repo.info.path,
          );
        case v0.AuthMode.noLocalPassword:
          oldPwdStorage = v0.SecureStorage(databaseId: databaseId);
          authMode = await _getNewAuthMode(
            oldPwdStorage,
            repo.name,
            repo.info.path,
          );
      }

      // The old settings did not include the '.db' extension in RepoLocation.
      final pathWithoutExt = repo.info.path;
      final location = RepoLocation.fromDbPath('$pathWithoutExt.db');

      // Try to write the auth mode to the repo metadata
      try {
        final repo = await Repository.open(session, store: location.path);
        await repo.setAuthMode(authMode);
        await repo.close();
      } catch (e, st) {
        loggy.error(
            'failed to migrate auth mode for repository ${location.path}:',
            e,
            st);
        continue;
      }

      // Remove the password from the old storage.
      if (oldPwdStorage != null) {
        await oldPwdStorage.deletePassword();
      }

      _root.repos[databaseId] = location;
    }

    await _storeRoot();

    // Remove repos that were successfully migrated
    for (final location in _root.repos.values) {
      await s0.forgetRepository(location.name);
    }

    // Remove the old repos entry if all repos successfully migrated.
    if (s0.repos().isEmpty) {
      await _prefs.remove(v0.Settings.knownRepositoriesKey);
    }

    // Remove keys that don't belong to this version of settings.  It's important
    // to do this **after** we've stored the root and version number of this
    // settings.
    for (final key in _prefs.getKeys()) {
      if (key == atomicSharedPrefsSettingsKey ||
          key == v0.Settings.knownRepositoriesKey) {
        continue;
      }

      await _prefs.remove(key);
    }
  }

  Future<AuthMode> _getNewAuthMode(
    v0.SecureStorage oldPwdStorage,
    String repoName,
    String path,
  ) async {
    AuthMode newAuthMode;
    final password = await oldPwdStorage.tryGetPassword(
      authMode: v0.AuthMode.noLocalPassword,
    );

    if (password == null) {
      final errorMessage =
          'Failed to migrate auth mode for repository repo: password is null';

      loggy.error('$errorMessage - $path');
      await Sentry.captureMessage(errorMessage);

      newAuthMode = AuthModeBlindOrManual();
      return newAuthMode;
    }

    newAuthMode = AuthModePasswordStoredOnDevice(
      await masterKey.encrypt(password),
      true,
    );

    return newAuthMode;
  }

  // Move all repos from the legacy location to the new location.
  Future<void> _migrateRepositoryPaths() async {
    switch (_root.defaultRepositoriesDirVersion) {
      case 0:
        // NOTE: We purposefully skip the android directories. This is because on android those
        // directories contain other stuff besides repositories so it's a bit more complicated to
        // migrate them correctly. More importantly, on android these directories are not visible
        // outside of this app and so it doesn't really matter where they are.
        // New repos are created in the new directory even on android though.
        final oldDirs = [
          io.Directory(
              join((await getApplicationDocumentsDirectory()).path, 'ouisync')),
          io.Directory(
              join((await getApplicationDocumentsDirectory()).path, 'Ouisync')),
        ];

        final newDir = await getDefaultRepositoriesDir();

        for (final oldDir in oldDirs) {
          if (!(await oldDir.exists())) {
            continue;
          }

          // Move files
          final statuses = await migrateFiles(oldDir, newDir);

          for (final status in statuses) {
            if (status.exception == null) {
              loggy.info(
                'moved repository ${status.oldPath} -> ${status.newPath}',
              );
            } else {
              loggy.error(
                'failed to move repository ${status.oldPath} -> ${status.newPath}:',
                status.exception,
              );
            }
          }

          final replacements = Map.fromEntries(statuses
              .where((status) => status.exception == null)
              .map((status) => MapEntry(
                    RepoLocation.fromDbPath(status.oldPath),
                    RepoLocation.fromDbPath(status.newPath),
                  )));

          // Update locations
          _root.repos.updateAll(
              (databaseId, location) => replacements[location] ?? location);

          _root.defaultRepo = _root.defaultRepo
              ?.let((location) => replacements[location] ?? location);
        }

        _root.defaultRepositoriesDirVersion = 1;

        await _storeRoot();
      case 1:
        return;
      default:
        loggy.error(
            'invalid defaultRepositoriesDirVersion: expected 0 or 1, was ${_root.defaultRepositoriesDirVersion}');
        return;
    }
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
    final baseDir = await Native.getBaseDir(removable: true);
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

  //------------------------------------------------------------------

  // Only for use in migrations!
  MigrationContext getMigrationContext() => MigrationContext(
        masterKey: masterKey,
        acceptedEqualitieValues: _root.acceptedEqualitieValues,
        showOnboarding: _root.showOnboarding,
        highestSeenProtocolNumber: _root.highestSeenProtocolNumber,
        defaultRepo: _root.defaultRepo?.clone(),
        repos: Map.from(_root.repos),
        defaultRepositoriesDirVersion: _root.defaultRepositoriesDirVersion,
        sharedPreferences: _prefs,
      );
}

class InvalidSettingsVersion implements Exception {
  int statedVersion;
  InvalidSettingsVersion(this.statedVersion);
  @override
  String toString() => "Invalid settings version ($statedVersion)";
}

class MigrationContext {
  final MasterKey masterKey;
  final bool acceptedEqualitieValues;
  final bool showOnboarding;
  // Intentionally not including this one as it's not used in V2.
  //final bool enableSyncOnMobileInternet;
  final int? highestSeenProtocolNumber;
  final RepoLocation? defaultRepo;
  final Map<DatabaseId, RepoLocation> repos;
  final int defaultRepositoriesDirVersion;
  final SharedPreferences sharedPreferences;

  MigrationContext({
    required this.masterKey,
    required this.acceptedEqualitieValues,
    required this.showOnboarding,
    required this.highestSeenProtocolNumber,
    required this.defaultRepo,
    required this.repos,
    required this.defaultRepositoriesDirVersion,
    required this.sharedPreferences,
  });
}
