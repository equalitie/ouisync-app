import 'dart:io' show Directory, Platform;
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/repo_meta_info.dart';
import '../utils.dart';

class DatabaseId {
  String _id;
  DatabaseId(String databaseId) : _id = databaseId {}

  @override
  String toString() => _id;
}

class SettingsRepoEntry {
  AuthMode authenticationMode;
  RepoMetaInfo info;

  String get name => info.name;
  Directory get dir => info.dir;

  SettingsRepoEntry(this.authenticationMode, this.info);

  Map toJson() {
    return {
      'authMode': authModeToString(authenticationMode),
      'location': info.path(),
    };
  }

  factory SettingsRepoEntry.fromJson(dynamic data) {
    return SettingsRepoEntry(authModeFromString(data['authMode']!)!,
        RepoMetaInfo.fromDbPath(data['location']!));
  }
}

class RepoSettings {
  DatabaseId _databaseId;
  SettingsRepoEntry _entry;

  RepoSettings(this._databaseId, this._entry);

  RepoMetaInfo get info => _entry.info;
  SettingsRepoEntry get entry => _entry;
  DatabaseId get databaseId => _databaseId;
  AuthMode get authenticationMode => _entry.authenticationMode;
  String get name => _entry.name;
  Directory get dir => _entry.dir;
}

class SettingsRoot {
  // Did the user accept the eQ values?
  bool acceptedEqualitieValues = false;
  // Show onboarding (will flip to false once shown).
  bool showOnboarding = true;
  bool launchAtStartup = true;
  bool enableSyncOnMobileInternet = true;
  int? highestSeenProtocolNumber;
  // TODO: In order to preserve plausible deniability, make sure that when a
  // current repo is locked, that this value is set to `null`.
  DatabaseId? currentRepo = null;
  Map<DatabaseId, SettingsRepoEntry> repos = {};

  SettingsRoot._();

  SettingsRoot({
    required this.acceptedEqualitieValues,
    required this.showOnboarding,
    required this.launchAtStartup,
    required this.enableSyncOnMobileInternet,
    required this.highestSeenProtocolNumber,
    required this.currentRepo,
    required this.repos,
  });

  Map<String, dynamic> toJson() {
    final r = {
      'acceptedEqualitieValues': acceptedEqualitieValues,
      'showOnboarding': showOnboarding,
      'launchAtStartup': launchAtStartup,
      'enableSyncOnMobileInternet': enableSyncOnMobileInternet,
      'highestSeenProtocolNumber': highestSeenProtocolNumber,
      'currentRepo': currentRepo?.toString(),
      'repos': <String, dynamic>{
        for (var kv in repos.entries) kv.key.toString(): kv.value.toJson()
      },
    };
    return r;
  }

  factory SettingsRoot.fromJson(String? s) {
    if (s == null) {
      return SettingsRoot._();
    }

    final data = json.decode(s);

    final repos = <DatabaseId, SettingsRepoEntry>{
      for (var kv in data['repos']!.entries)
        DatabaseId(kv.key): SettingsRepoEntry.fromJson(kv.value)
    };

    return SettingsRoot(
      acceptedEqualitieValues: data['acceptedEqualitieValues']!,
      showOnboarding: data['showOnboarding']!,
      launchAtStartup: data['launchAtStartup']!,
      enableSyncOnMobileInternet: data['enableSyncOnMobileInternet']!,
      highestSeenProtocolNumber: data['highestSeenProtocolNumber'],
      currentRepo: DatabaseId(data['currentRepo']!),
      repos: repos,
    );
  }
}

class Settings with AppLogger {
  static const String SETTINGS_KEY = "settingsV1";

  final SettingsRoot _root;
  final SharedPreferences _prefs;

  //------------------------------------------------------------------

  Settings._(this._root, this._prefs);

  Future<void> _storeRoot() async {
    await _prefs.setString(SETTINGS_KEY, json.encode(_root.toJson()));
  }

  static Future<Settings> init(SharedPreferences prefs) async {
    final json = prefs.getString(SETTINGS_KEY);
    final root = SettingsRoot.fromJson(json);

    if (prefs.getKeys().length > 2) {
      // The previous migration did not finish correctly, prefs should only
      // contain the `SETTINGS_VERSION` key and the `SETTINGS_KEY` key after
      // success.
      return await initFromMigration(root, prefs);
    }

    return Settings._(root, prefs);
  }

  static Future<Settings> initFromMigration(
      SettingsRoot root, SharedPreferences prefs) async {
    final settings = Settings._(root, prefs);

    await settings._storeRoot();
    await prefs.setInt(SETTINGS_VERSION_KEY, 1);

    // Remove keys that don't belong to this version of settings.  It's
    // important to do this **after** we've stored the root and version number
    // above to avoid data loss.
    for (final key in prefs.getKeys()) {
      if (key != SETTINGS_VERSION_KEY && key != SETTINGS_KEY) {
        await prefs.remove(key);
      }
    }

    return settings;
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

  Iterable<RepoSettings> repos() =>
      _root.repos.entries.map((kv) => RepoSettings(kv.key, kv.value));

  //------------------------------------------------------------------

  RepoSettings? repoSettingsByName(String name) {
    var e = null;
    for (final kv in _root.repos.entries) {
      if (kv.value.name == name) {
        e = kv;
        break;
      }
    }
    if (e == null) {
      return null;
    }
    return RepoSettings(e.key, e.value);
  }

  //------------------------------------------------------------------

  String? getDefaultRepo() {
    final current = _root.currentRepo;
    if (current == null) {
      return null;
    }
    _root.repos[current]?.info.name;
  }

  Future<void> setDefaultRepo(String? name) async {
    // TODO: We should not set repositories that are protected by passwords as
    // default because that could imply that those repositories are not blind
    // and thus compromise plausible deniability.
    if (_root.currentRepo == name) {
      return;
    }

    if (name == null) {
      _root.currentRepo = null;
    } else {
      final rs = repoSettingsByName(name);
      if (rs == null) {
        return null;
      }
      _root.currentRepo = rs.databaseId;
    }

    await _storeRoot();
  }

  //------------------------------------------------------------------

  Future<void> renameRepository(
      RepoSettings repoSettings, String newName) async {
    if (repoSettings.name == newName) {
      // TODO: This should just return without throwing, but check where it's used.
      throw 'Failed to rename repo: "$newName" to same name';
    }

    if (repoSettingsByName(newName) != null) {
      throw 'Failed to rename repo: "$newName" already exists';
    }

    final oldInfo = repoSettings.entry.info;
    repoSettings.entry.info = RepoMetaInfo.fromDirAndName(oldInfo.dir, newName);
    await _storeRoot();
  }

  //------------------------------------------------------------------

  Future<RepoSettings?> addRepo(
    RepoMetaInfo info, {
    required DatabaseId databaseId,
    required AuthMode authenticationMode,
  }) async {
    if (_root.repos.containsKey(databaseId)) {
      loggy.debug(
          'Settings already contains a repo with the id "${databaseId}"');
      return null;
    }

    if (repoSettingsByName(info.name) != null) {
      loggy.debug(
          'Settings already contains a repo with the name "${info.name}"');
      return null;
    }

    final entry = SettingsRepoEntry(authenticationMode, info);
    _root.repos[databaseId] = entry;

    await _storeRoot();

    return RepoSettings(databaseId, entry);
  }

  //------------------------------------------------------------------

  Future<void> forgetRepository(DatabaseId databaseId) async {
    if (_root.currentRepo == databaseId) {
      _root.currentRepo = null;
    }
    _root.repos.remove(databaseId);
    await _storeRoot();
  }

  //------------------------------------------------------------------

  AuthMode getAuthenticationMode(String repoName) {
    return repoSettingsByName(repoName)!.authenticationMode;
  }

  Future<void> setAuthenticationMode(String repoName, AuthMode value) async {
    repoSettingsByName(repoName)!._entry.authenticationMode = value;
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
        context.join(alternativeDir.path, 'ouisync');

    return await Directory(nonAndroidAlternativePath).create();
  }

  //------------------------------------------------------------------

  String? getMountPoint() => _defaultMountPoint();
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
