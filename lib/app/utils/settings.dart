import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For json

import 'utils.dart';

class Settings {
  static SharedPreferences? _prefs;

  static const String _CURRENT_REPO_KEY = "CURRENT_REPO";
  static const String _BT_DHT_KEY_PREFIX = "BT_DHT_ENABLED-";
  static const String _HIGHEST_SEEN_PROTOCOL_NUMBER_KEY = "HIGHEST_SEEN_PROTOCOL_NUMBER";

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
    final prefs = await _init();

    if (name != null && name.isNotEmpty) {
      await prefs.setString(_CURRENT_REPO_KEY, name);
    } else {
      await _remove(prefs, _CURRENT_REPO_KEY);
    }
  }

  static Future<String?> getDefaultRepo() async {
    return await (await _init()).getString(_CURRENT_REPO_KEY);
  }

  static Future<bool> getDhtEnableStatus(String repoId, { required bool defaultValue }) async {
    final prefs = await _init();

    final status = await prefs.getBool(_BT_DHT_KEY_PREFIX + repoId);
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
    await prefs.getInt(_HIGHEST_SEEN_PROTOCOL_NUMBER_KEY);
  }

  // TODO: It's not clear from the documentation whether
  // SharedPreferences.remove throws if the key doesn't exist (it might also be
  // platform dependent), so we check for it.
  static Future<void> _remove(SharedPreferences prefs, String key) async {
    try { await prefs.remove(key); } catch (_) {}
  }
}
