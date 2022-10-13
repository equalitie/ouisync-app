import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const String _currentRepoKey = "CURRENT_REPO";
  static const String _syncOnMobileKey = "SYNC_ON_MOBILE";
  static const String _highestSeenProtocolNumberKey =
      "HIGHEST_SEEN_PROTOCOL_NUMBER";
  static const String _repositoriesPrefix = "REPOSITORIES";
  static const String _dhtEnabledKey = "DHT_ENABLED";
  static const String _pexEnabledKey = "PEX_ENABLED";

  final SharedPreferences _prefs;
  final _CachedString _defaultRepo;

  Settings._(this._prefs)
      : _defaultRepo = _CachedString(_currentRepoKey, _prefs);

  static Future<Settings> init() async {
    final prefs = await SharedPreferences.getInstance();
    return Settings._(prefs);
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

  Future<void> forgetRepository(String repoName) async {
    if (_defaultRepo.get() == repoName) {
      await _defaultRepo.set(null);
    }

    await setDhtEnabled(repoName, null);
    await setPexEnabled(repoName, null);
  }

  bool? getDhtEnabled(String repoName) =>
      _prefs.getBool(_repositoryKey(repoName, _dhtEnabledKey));

  Future<void> setDhtEnabled(String repoName, bool? value) =>
      _setRepositoryBool(repoName, _dhtEnabledKey, value);

  bool? getPexEnabled(String repoName) =>
      _prefs.getBool(_repositoryKey(repoName, _pexEnabledKey));

  Future<void> setPexEnabled(String repoName, bool? value) =>
      _setRepositoryBool(repoName, _pexEnabledKey, value);

  Future<void> setEnableSyncOnMobile(bool enable) async {
    await _prefs.setBool(_syncOnMobileKey, enable);
  }

  bool getEnableSyncOnMobile(bool default_) {
    return _prefs.getBool(_syncOnMobileKey) ?? default_;
  }

  Future<void> setHighestSeenProtocolNumber(int number) async {
    await _prefs.setInt(_highestSeenProtocolNumberKey, number);
  }

  int? getHighestSeenProtocolNumber() {
    return _prefs.getInt(_highestSeenProtocolNumberKey);
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
    final escapedName = repoName.replaceAll('/', '_');
    return "$_repositoriesPrefix/$escapedName/$key";
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
