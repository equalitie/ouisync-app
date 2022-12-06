import 'dart:io' as io;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/repo_meta_info.dart';
import 'constants.dart';
import 'log_reader.dart';

class Settings {
  // Per app settings
  static const String _currentRepoKey = "CURRENT_REPO";
  static const String _syncOnMobileKey = "SYNC_ON_MOBILE";
  static const String _highestSeenProtocolNumberKey =
      "HIGHEST_SEEN_PROTOCOL_NUMBER";
  static const String _portForwardingEnabledKey = "PORT_FORWARDING_ENABLED";
  static const String _localDiscoveryEnabledKey = "LOCAL_DISCOVERY_ENABLED";

  // Per repository settings
  static const String _repositoryPrefix = "REPOSITORIES";
  static const String _dhtEnabledKey = "DHT_ENABLED";
  static const String _pexEnabledKey = "PEX_ENABLED";
  static const String _logViewFilterKey = "LOG_VIEW/FILTER";

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

    return Settings._(prefs, repos);
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
    return await path_provider.getApplicationDocumentsDirectory();
  }

  List<RepoMetaInfo> repos() {
    final knownRepos = _prefs.getStringList(_knownRepositoriesKey);

    if (knownRepos == null) {
      return <RepoMetaInfo>[];
    }

    return knownRepos.map((path) => RepoMetaInfo.fromDbPath(path)).toList();
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

  Future<void> renameRepository(String oldName, String newName) async {
    if (oldName == newName) {
      return;
    }

    if (_defaultRepo.get() == oldName) {
      await _defaultRepo.set(newName);
    }

    await setDhtEnabled(newName, getDhtEnabled(oldName));
    await setDhtEnabled(oldName, null);

    await setPexEnabled(newName, getPexEnabled(oldName));
    await setPexEnabled(oldName, null);
  }

  Future<bool> addRepo(RepoMetaInfo info) async {
    if (_repos.containsKey(info.name)) {
      return false;
    }

    _repos[info.name] = info.dir.path;

    _storeRepos(_prefs, _repos);

    return true;
  }

  Future<void> forgetRepository(String repoName) async {
    if (_defaultRepo.get() == repoName) {
      await _defaultRepo.set(null);
    }

    await setDhtEnabled(repoName, null);
    await setPexEnabled(repoName, null);

    _repos.remove(repoName);
    _storeRepos(_prefs, _repos);
  }

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

  Future<void> _setRepositoryBool(
      String repoName, String key, bool? value) async {
    final fullKey = _repositoryKey(repoName, key);

    if (value != null) {
      await _prefs.setBool(fullKey, value);
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

    prefs.setBool(_legacyReposIncluded, true);
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
