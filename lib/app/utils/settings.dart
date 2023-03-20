import 'dart:io' as io show Directory, Platform;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/repo_meta_info.dart';
import 'constants.dart';
import 'log_reader.dart';

class SettingsRepoEntry {
  String databaseId;
  RepoMetaInfo info;

  String get name => info.name;
  io.Directory get dir => info.dir;

  SettingsRepoEntry(this.databaseId, this.info);
}

class Settings {
  // Per app settings
  static const String _currentRepoKey = "CURRENT_REPO";
  static const String _syncOnMobileKey = "SYNC_ON_MOBILE";
  static const String _highestSeenProtocolNumberKey =
      "HIGHEST_SEEN_PROTOCOL_NUMBER";
  static const String _portForwardingEnabledKey = "PORT_FORWARDING_ENABLED";
  static const String _localDiscoveryEnabledKey = "LOCAL_DISCOVERY_ENABLED";
  static const String _logViewFilterKey = "LOG_VIEW/FILTER";

  // Per repository settings
  static const String _repositoryPrefix = "REPOSITORIES";
  static const String _databaseId = "DATABASE_ID";
  static const String _dhtEnabledKey = "DHT_ENABLED";
  static const String _pexEnabledKey = "PEX_ENABLED";

  /// When securing the password using biometrics, we used the biometric_storage
  /// plugin, and its built in biometrics authentication (by default:
  /// authenticationRequired=true).
  ///
  /// Now we are still using the biometric_storage, but not its built in
  /// biometrics authentication. The biometric authentication it's done using
  /// the Dart package, local_auth.
  ///
  /// AUTH_MODE is null, if the repository was created before this update,
  /// in which case the value is determined as follow:
  ///
  /// manual = Manual password input by the user.
  ///
  /// version1 = Password secured with biometrics, using built in validation
  /// in biometrics_storage. (authenticationRequired=true)
  ///
  /// version2 = Password secured with biometrics, using biometrics_storage for
  /// storage, and local_auth for biometric validation.
  /// (authenticationRequired=false)
  ///
  /// no_local_password = Password saved to biometric_storage, no biometric
  /// validation for retrieving. It's equivalent to automatic unlocking.
  static const String _authenticationMode = "AUTH_MODE";

  // List of all repositories this app is concerned about
  static const String _knownRepositoriesKey = "KNOWN_REPOSITORIES";

  // In the past we had only a single directory (`_legacyReposDirectory`) where
  // we stored all repositories. To know what repositories we have we would
  // just list that directory.  To be able to store the repositories at other
  // locations we started to keep track of which repositories to use in this
  // settings. To stay compatible with previous versions we use this
  // `_legacyReposIncluded` flag to indicate whether we checked the legacy
  // directory and moved everything there into this settings.
  static const String _legacyReposIncluded = "LEGACY_REPOS_INCLUDED";

  final SharedPreferences _prefs;
  final _CachedString _defaultRepo;

  // Key is the repository name (file name without the extension), Value is the
  // path to the directory where the repository file is located.
  final Map<String, String> _repos;

  Settings._(this._prefs, this._repos)
      : _defaultRepo = _CachedString(_currentRepoKey, _prefs);

  static Future<Settings> init() async {
    final prefs = await SharedPreferences.getInstance();

    final repos = <String, String>{};

    final repoPaths = prefs.getStringList(_knownRepositoriesKey);

    if (repoPaths != null) {
      for (final path in repoPaths) {
        final repo = RepoMetaInfo.fromDbPath(path);
        repos[repo.name] = repo.dir.path;
      }
    }

    if (await _includeLegacyRepos(prefs, repos)) {
      await _storeRepos(prefs, repos);
    }

    final settings = Settings._(prefs, repos);

    await settings._migrateIds();

    return settings;
  }

  Future<void> _migrateIds() async {
    for (final entry in _repos.entries) {
      if (_getDatabaseIdMaybe(entry.key) == null) {
        // We used to have biometric data stored under repository names, but
        // that caused problems with repository renaming. So we introduced
        // database IDs but in order to not invalidate previously stored
        // biometrics, we use the old names as IDs for old repositories. For
        // any newly created repository we'll use a database ID provided by the
        // repository.
        await _setDatabaseId(entry.key, entry.key);
      }
    }
  }

  static Future<void> _storeRepos(
      SharedPreferences prefs, Map<String, String> repos) async {
    await prefs.setStringList(_knownRepositoriesKey,
        repos.entries.map((e) => p.join(e.value, e.key)).toList());
  }

  Future<io.Directory> defaultRepoLocation() async {
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
    if (io.Platform.isAndroid) {
      return alternativeDir;
    }

    final context = p.Context(style: p.Style.posix);
    final nonAndroidAlternativePath =
        context.join(alternativeDir.path, 'ouisync');

    final documents = await io.Directory(nonAndroidAlternativePath).create();
    return documents;
  }

  List<SettingsRepoEntry> repos() {
    final paths = _prefs.getStringList(_knownRepositoriesKey);

    if (paths == null) {
      return <SettingsRepoEntry>[];
    }

    return paths.map((path) {
      final info = RepoMetaInfo.fromDbPath(path);
      final id = getDatabaseId(info.name);
      return SettingsRepoEntry(id, info);
    }).toList();
  }

  SettingsRepoEntry? entryByName(String name) {
    final info = repoMetaInfo(name);
    if (info == null) return null;
    final id = getDatabaseId(name);
    return SettingsRepoEntry(id, info);
  }

  RepoMetaInfo? repoMetaInfo(String repoName) {
    final dir = _repos[repoName];
    if (dir == null) return null;
    return RepoMetaInfo.fromDirAndName(io.Directory(dir), repoName);
  }

  Future<void> setDefaultRepo(String? name) async {
    await _defaultRepo.set(name);
  }

  String? getDefaultRepo() {
    return _defaultRepo.get();
  }

  Future<SettingsRepoEntry?> renameRepository(
      String oldName, String newName) async {
    if (oldName == newName) {
      return null;
    }

    if (_repos.containsKey(newName)) {
      print("Failed to rename repo: \"$newName\" already exists");
      return null;
    }

    if (_defaultRepo.get() == oldName) {
      await _defaultRepo.set(newName);
    }

    final path = _repos[oldName]!;
    _repos[newName] = path;

    final databaseId = getDatabaseId(oldName);
    await _setDatabaseId(newName, databaseId);
    await setDhtEnabled(newName, getDhtEnabled(oldName));
    await setPexEnabled(newName, getPexEnabled(oldName));
    await setAuthenticationMode(newName, getAuthenticationMode(oldName));

    await forgetRepository(oldName);

    return SettingsRepoEntry(
        databaseId, RepoMetaInfo.fromDirAndName(io.Directory(path), newName));
  }

  Future<SettingsRepoEntry?> addRepo(RepoMetaInfo info,
      {required String databaseId, required String authenticationMode}) async {
    if (_repos.containsKey(info.name)) {
      print("Settings already contains a repo with the name \"${info.name}\"");
      return null;
    }

    _repos[info.name] = info.dir.path;
    await _setDatabaseId(info.name, databaseId);
    await _storeRepos(_prefs, _repos);
    await setAuthenticationMode(info.name, authenticationMode);

    return SettingsRepoEntry(databaseId, info);
  }

  Future<void> forgetRepository(String repoName) async {
    if (_defaultRepo.get() == repoName) {
      await _defaultRepo.set(null);
    }

    await _setDatabaseId(repoName, null);
    await setDhtEnabled(repoName, null);
    await setPexEnabled(repoName, null);
    await setAuthenticationMode(repoName, null);

    _repos.remove(repoName);
    await _storeRepos(_prefs, _repos);
  }

  String getDatabaseId(String repoName) => _getDatabaseIdMaybe(repoName)!;

  String? _getDatabaseIdMaybe(String repoName) =>
      _prefs.getString(_repositoryKey(repoName, _databaseId));

  Future<void> _setDatabaseId(String repoName, String? databaseId) =>
      _setRepositoryString(repoName, _databaseId, databaseId);

  bool? getDhtEnabled(String repoName) =>
      _prefs.getBool(_repositoryKey(repoName, _dhtEnabledKey));

  Future<void> setDhtEnabled(String repoName, bool? value) =>
      _setRepositoryBool(repoName, _dhtEnabledKey, value);

  bool? getPexEnabled(String repoName) =>
      _prefs.getBool(_repositoryKey(repoName, _pexEnabledKey));

  Future<void> setPexEnabled(String repoName, bool? value) =>
      _setRepositoryBool(repoName, _pexEnabledKey, value);

  bool? getPortForwardingEnabled() => _prefs.getBool(_portForwardingEnabledKey);

  Future<void> setPortForwardingEnabled(bool value) =>
      _prefs.setBool(_portForwardingEnabledKey, value);

  bool? getLocalDiscoveryEnabled() => _prefs.getBool(_localDiscoveryEnabledKey);

  Future<void> setLocalDiscoveryEnabled(bool value) =>
      _prefs.setBool(_localDiscoveryEnabledKey, value);

  bool? getSyncOnMobileEnabled() => _prefs.getBool(_syncOnMobileKey);

  Future<void> setSyncOnMobileEnabled(bool enable) async {
    await _prefs.setBool(_syncOnMobileKey, enable);
  }

  Future<void> setHighestSeenProtocolNumber(int number) async {
    await _prefs.setInt(_highestSeenProtocolNumberKey, number);
  }

  int? getHighestSeenProtocolNumber() {
    return _prefs.getInt(_highestSeenProtocolNumberKey);
  }

  LogLevel getLogViewFilter() =>
      LogLevel.parse(_prefs.getString(_logViewFilterKey) ?? '');

  Future<void> setLogViewFilter(LogLevel value) async {
    await _prefs.setString(_logViewFilterKey, value.toShortString());
  }

  String? getAuthenticationMode(String repoName) =>
      _prefs.getString(_repositoryKey(repoName, _authenticationMode));

  Future<void> setAuthenticationMode(String repoName, String? value) async =>
      _setRepositoryString(repoName, _authenticationMode, value);

  Future<void> _setRepositoryBool(
      String repoName, String key, bool? value) async {
    final fullKey = _repositoryKey(repoName, key);

    if (value != null) {
      await _prefs.setBool(fullKey, value);
    } else {
      await _prefs.remove(fullKey);
    }
  }

  Future<void> _setRepositoryString(
      String repoName, String key, String? value) async {
    final fullKey = _repositoryKey(repoName, key);

    if (value != null) {
      await _prefs.setString(fullKey, value);
    } else {
      await _prefs.remove(fullKey);
    }
  }

  // TODO: It's not clear from the documentation whether
  // SharedPreferences.remove throws if the key doesn't exist (it might also be
  // platform dependent), so we check for it.
  static Future<void> _remove(SharedPreferences prefs, String key) async {
    try {
      await prefs.remove(key);
    } catch (_) {}
  }

  static String _repositoryKey(String repoName, String key) {
    // TODO: This replacing is problematic because if we had repositories named
    // "foo/bar" and "foo_bar", they would override each other.
    final escapedName = repoName.replaceAll('/', '_');
    return "$_repositoryPrefix/$escapedName/$key";
  }

  static Future<bool> _includeLegacyRepos(
      SharedPreferences prefs, Map<String, String> repos) async {
    final includedAlready = prefs.getBool(_legacyReposIncluded);

    if (includedAlready != null && includedAlready == true) {
      //return false;
    }

    // We used to have all the repositories in a single place in the internal
    // memory. The disadvantage was that the user had no access to them and
    // thus couldn't back them up or put them on an SD card.
    final dir = io.Directory(p.join(
        (await path_provider.getApplicationSupportDirectory()).path,
        Constants.folderRepositoriesName));

    if (!await dir.exists()) {
      return false;
    }

    await for (final file in dir.list()) {
      if (!file.path.endsWith(".db")) {
        continue;
      }

      assert(p.isAbsolute(file.path));
      final info = RepoMetaInfo.fromDbPath(file.path);
      repos[info.name] = info.dir.path;
    }

    await prefs.setBool(_legacyReposIncluded, true);
    return true;
  }
}

class _CachedString {
  String? _value;
  final String _key;
  final SharedPreferences _prefs;

  _CachedString(this._key, this._prefs);

  String? get() {
    return _prefs.getString(_key);
  }

  Future<void> set(String? newValue) async {
    if (_value == newValue) {
      return;
    }

    _value = newValue;

    if (newValue != null) {
      await _prefs.setString(_key, newValue);
    } else {
      await Settings._remove(_prefs, _key);
    }
  }
}
