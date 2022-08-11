import 'package:shared_preferences/shared_preferences.dart';
// For json

import 'utils.dart';

class Settings {
  static SharedPreferences? _prefs;

  static const String _CURRENT_REPO_KEY = "CURRENT_REPO";
  static const String _BT_DHT_KEY_PREFIX = "BT_DHT_ENABLED-";
  static const String _HIGHEST_SEEN_PROTOCOL_NUMBER_KEY = "HIGHEST_SEEN_PROTOCOL_NUMBER";

  static _CachedString _defaultRepo = _CachedString(_CURRENT_REPO_KEY);

  static Future<SharedPreferences> _init() async {
    var prefs = _prefs;
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
    }
    return prefs;
  }

  static Future<void> initSettings(
    String appDir,
    String repositoriesDir,
  ) async {
    final prefs = await _init();

    await prefs.setString(Constants.appDirKey, appDir);
    await prefs.setString(Constants.repositoriesDirKey, repositoriesDir);
  }

  static Future<void> setDefaultRepo(String? name) async {
    await _defaultRepo.set(name);
  }

  static Future<String?> getDefaultRepo() async {
    return _defaultRepo.get();
  }

  static Future<bool> getDhtEnableStatus(String repoId, { required bool defaultValue }) async {
    final prefs = await _init();

    final status = prefs.getBool(_BT_DHT_KEY_PREFIX + repoId);
    return status ?? defaultValue;
  }

  static Future<void> setDhtEnableStatus(String repoId, bool? status) async {
    final prefs = await _init();
    final key = _BT_DHT_KEY_PREFIX + repoId;

    if (status != null) {
      await prefs.setBool(key, status);
    } else {
      await _remove(prefs, key);
    }
  }

  static Future<void> setHighestSeenProtocolNumber(int number) async {
    final prefs = await _init();
    await prefs.setInt(_HIGHEST_SEEN_PROTOCOL_NUMBER_KEY, number);
  }

  static Future<int?> getHighestSeenProtocolNumber() async {
    final prefs = await _init();
    prefs.getInt(_HIGHEST_SEEN_PROTOCOL_NUMBER_KEY);
    return null;
  }

  // TODO: It's not clear from the documentation whether
  // SharedPreferences.remove throws if the key doesn't exist (it might also be
  // platform dependent), so we check for it.
  static Future<void> _remove(SharedPreferences prefs, String key) async {
    try { await prefs.remove(key); } catch (_) {}
  }
}

class _CachedString {
  String? _value = null;
  bool _isKnown = false;
  String _key;

  _CachedString(this._key);

  Future<String?> get() async {
    if (_isKnown) {
      return _value;
    }

    _value = (await Settings._init()).getString(_key);
    _isKnown = true;
    return _value;
  }

  Future<void> set(String? newValue) async {
    if (_isKnown && _value == newValue) {
      return;
    }

    _isKnown = true;
    _value = newValue;

    final prefs = await Settings._init();

    if (newValue != null) {
      await prefs.setString(_key, newValue);
    } else {
      await Settings._remove(prefs, _key);
    }
  }
}
