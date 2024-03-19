import 'dart:io' show Directory, Platform;
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../utils.dart';
import '../master_key.dart';
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

  // Did the user accept the eQ values?
  bool acceptedEqualitieValues = false;
  // Show onboarding (will flip to false once shown).
  bool showOnboarding = true;
  bool launchAtStartup = true;
  bool enableSyncOnMobileInternet = true;
  int? highestSeenProtocolNumber;
  // NOTE: In order to preserve plausible deniability, once the current repo is
  // locked in _AuthModeBlindOrManual, this value must set to `null`.
  RepoLocation? defaultRepo;
  Map<DatabaseId, RepoLocation> repos = {};

  SettingsRoot._();

  SettingsRoot({
    required this.acceptedEqualitieValues,
    required this.showOnboarding,
    required this.launchAtStartup,
    required this.enableSyncOnMobileInternet,
    required this.highestSeenProtocolNumber,
    required this.defaultRepo,
    required this.repos,
  });

  Map<String, dynamic> toJson() {
    final r = {
      'version': version,
      'acceptedEqualitieValues': acceptedEqualitieValues,
      'showOnboarding': showOnboarding,
      'launchAtStartup': launchAtStartup,
      'enableSyncOnMobileInternet': enableSyncOnMobileInternet,
      'highestSeenProtocolNumber': highestSeenProtocolNumber,
      'defaultRepo': defaultRepo?.path,
      'repos': <String, Object?>{
        for (var kv in repos.entries) kv.key.toString(): kv.value.path
      },
    };
    return r;
  }

  factory SettingsRoot.fromJson(String? s) {
    if (s == null) {
      return SettingsRoot._();
    }

    final data = json.decode(s);

    int inputVersion = data['version'];

    if (inputVersion != version) {
      throw "Invalid settings version ($inputVersion)";
    }

    final repos = {
      for (var kv in data['repos']!.entries)
        DatabaseId(kv.key): RepoLocation.fromDbPath(kv.value)
    };

    String? defaultRepo = data['defaultRepo'];

    return SettingsRoot(
      acceptedEqualitieValues: data['acceptedEqualitieValues']!,
      showOnboarding: data['showOnboarding']!,
      launchAtStartup: data['launchAtStartup']!,
      enableSyncOnMobileInternet: data['enableSyncOnMobileInternet']!,
      highestSeenProtocolNumber: data['highestSeenProtocolNumber'],
      defaultRepo: defaultRepo?.let((path) => RepoLocation.fromDbPath(path)),
      repos: repos,
    );
  }
}

class Settings with AppLogger {
  static const String settingsKey = "settings";

  final MasterKey masterKey;

  final SettingsRoot _root;
  final SharedPreferences _prefs;

  //------------------------------------------------------------------

  Settings._(this._root, this._prefs, this.masterKey);

  Future<void> _storeRoot() async {
    await _prefs.setString(settingsKey, json.encode(_root.toJson()));
  }

  static Future<Settings> init(
    SharedPreferences prefs,
    MasterKey masterKey,
  ) async {
    final json = prefs.getString(settingsKey);
    final root = SettingsRoot.fromJson(json);

    if (prefs.getKeys().length > 1) {
      // The previous migration did not finish correctly, prefs should only
      // `settingsKey` key after success.
      await Settings._removeValuesFromV0(prefs);
    }

    return Settings._(root, prefs, masterKey);
  }

  static Future<Settings> initMigrateFromV0(
    SharedPreferences prefs,
    MasterKey masterKey,
  ) async {
    final s0 = await v0.Settings.init(prefs);
    final eqValues = s0.getEqualitieValues();
    final showOnboarding = s0.getShowOnboarding();
    final launchAtStartup = s0.getLaunchAtStartup();
    final enableSyncOnMobileInternet = s0.getSyncOnMobileEnabled();
    final highestSeenProtocolNumber = s0.getHighestSeenProtocolNumber();
    final defaultRepo = s0.getDefaultRepo();

    final Map<DatabaseId, RepoLocation> repos = {};

    for (final repo in s0.repos()) {
      final id = DatabaseId(repo.databaseId);
      final auth = s0.getAuthenticationMode(repo.name);
      AuthMode? newAuth;
      v0.SecureStorage? oldPwdStorage;
      switch (auth) {
        case v0.AuthMode.manual:
          newAuth = AuthModeBlindOrManual();
        case v0.AuthMode.version1:
        case v0.AuthMode.version2:
          oldPwdStorage = v0.SecureStorage(databaseId: id);
          final password = await oldPwdStorage.tryGetPassword(
            authMode: v0.AuthMode.noLocalPassword,
          );
          newAuth = AuthModePasswordStoredOnDevice(
            await masterKey.encrypt(password!),
            true,
          );
        case v0.AuthMode.noLocalPassword:
          oldPwdStorage = v0.SecureStorage(databaseId: id);
          final password = await oldPwdStorage.tryGetPassword(
            authMode: v0.AuthMode.noLocalPassword,
          );
          newAuth = AuthModePasswordStoredOnDevice(
            await masterKey.encrypt(password!),
            false,
          );
      }
      // Remove the password from the old storage.
      if (oldPwdStorage != null) {
        await oldPwdStorage.deletePassword();
      }
      // The old settings did not include the '.db' extension in RepoLocation.
      final pathWithoutExt = repo.info.path;
      repos[id] = RepoLocation.fromDbPath("$pathWithoutExt.db");
    }

    final root = SettingsRoot(
      acceptedEqualitieValues: eqValues,
      showOnboarding: showOnboarding,
      launchAtStartup: launchAtStartup,
      enableSyncOnMobileInternet: enableSyncOnMobileInternet,
      highestSeenProtocolNumber: highestSeenProtocolNumber,
      defaultRepo: defaultRepo?.let((id) => repos[DatabaseId(id)]),
      repos: repos,
    );

    final s1 = Settings._(root, prefs, masterKey);

    // The order of these operations is important to avoid data loss.
    await s1._storeRoot();
    await Settings._removeValuesFromV0(prefs);

    return s1;
  }

  // Remove keys that don't belong to this version of settings.  It's important
  // to do this **after** we've stored the root and version number of this
  // settings.
  static Future<void> _removeValuesFromV0(SharedPreferences prefs) async {
    for (final key in prefs.getKeys()) {
      if (key != settingsKey) {
        await prefs.remove(key);
      }
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

  bool getLaunchAtStartup() => _root.launchAtStartup;

  Future<void> setLaunchAtStartup(bool value) async {
    _root.launchAtStartup = value;
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

  Future<Directory> defaultRepoLocation() async {
    // TODO
    try {
      // Docs says this throws on non Android systems.
      // https://pub.dev/documentation/path_provider/latest/path_provider/getExternalStorageDirectory.html
      //
      // On Android this function will most likely return the user accessible
      // directory on phone's internal memory (i.e. not the SDCard). The user
      // will see it as "<DEVICE>/Phone/Android/data/org.equalitie.ouisync/files"
      //
      // Everything in this folder is deleted when the app is un/re-installed.
      final dir = await path_provider.getExternalStorageDirectory();
      if (dir != null) {
        return dir;
      }
    } catch (_) {}

    // This path is not accessible by the user using a file explorer and it
    // also gets deleted when the app is un/re-installed.
    final alternativeDir =
        await path_provider.getApplicationDocumentsDirectory();

    if (Platform.isAndroid) {
      return alternativeDir;
    }

    final context = p.Context(style: p.Style.posix);

    final nonAndroidAlternativePath =
        context.join(alternativeDir.path, 'Ouisync');

    return await Directory(nonAndroidAlternativePath).create();
  }

  //------------------------------------------------------------------

  String? getMountPoint() => _defaultMountPoint();

  void debugPrint() {
    print("============== Settings ===============");
    for (final kv in _root.repos.entries) {
      print("=== ${kv.key}");
    }
    print("=======================================");
  }
}

String? _defaultMountPoint() {
  if (Platform.isLinux || Platform.isMacOS) {
    final home = Platform.environment['HOME'];

    if (home == null) {
      return null;
    }

    return '$home/Ouisync';
  } else if (Platform.isWindows) {
    return 'O:';
  } else {
    return null;
  }
}
