import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const String _currentRepoKey = "CURRENT_REPO";
  static const String _syncOnMobileKey = "SYNC_ON_MOBILE";
  static const String _btDhtKeyPrefix = "BT_DHT_ENABLED-";
  static const String _highestSeenProtocolNumberKey =
      "HIGHEST_SEEN_PROTOCOL_NUMBER";

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

    final dhtStatus = _getDhtEnableStatus(oldName);
    await setDhtEnableStatus(oldName, null);
    await setDhtEnableStatus(newName, dhtStatus);
  }

  Future<void> forgetRepository(String repoName) async {
    if (_defaultRepo.get() == repoName) {
      await _defaultRepo.set(null);
    }

    await setDhtEnableStatus(repoName, null);
  }

  // Note: Using the repository name instead of it's ID because we know the name without
  // having to open the repository first. So in the future we will be able to pass this
  // value to the function that opens the repository.
  bool getDhtEnableStatus(String repoName, {required bool defaultValue}) {
    return _getDhtEnableStatus(repoName) ?? defaultValue;
  }

  bool? _getDhtEnableStatus(String repoName) {
    return _prefs.getBool(_btDhtKeyPrefix + repoName);
  }

  Future<void> setDhtEnableStatus(String repoName, bool? status) async {
    final key = _btDhtKeyPrefix + repoName;

    if (status != null) {
      await _prefs.setBool(key, status);
    } else {
      await _remove(_prefs, key);
    }
  }

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

  // TODO: It's not clear from the documentation whether
  // SharedPreferences.remove throws if the key doesn't exist (it might also be
  // platform dependent), so we check for it.
  static Future<void> _remove(SharedPreferences prefs, String key) async {
    try {
      await prefs.remove(key);
    } catch (_) {}
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
