import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For json

import 'utils.dart';

class Settings {
  static SharedPreferences? _prefs;

  static const String _CURRENT_REPO_KEY = "CURRENT_REPO";
  static const String _BT_DHT_KEY = "BT_DHT";
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
      await prefs.remove(_CURRENT_REPO_KEY);
    }
  }

  static Future<String?> getDefaultRepo() async {
    return await (await _init()).getString(_CURRENT_REPO_KEY);
  }

  static Future<Map<String, bool>> getDhtStatus() async {
    final prefs = await _init();

    final encodedDhtStatus = await prefs.getString(_BT_DHT_KEY);

    return encodedDhtStatus == null 
      ? Map<String, bool>()
      : Map<String, bool>.from(json.decode(encodedDhtStatus));
  }

  static Future<void> setDhtStatus(Map<String, bool> dhtStatus) async {
    final encodedDhtStatus = json.encode(dhtStatus);
    final prefs = await _init();
    await prefs.setString(_BT_DHT_KEY, encodedDhtStatus);
  }

  static Future<void> setHighestSeenProtocolNumber(int number) async {
    final prefs = await _init();
    await prefs.setInt(_HIGHEST_SEEN_PROTOCOL_NUMBER_KEY, number);
  }

  static Future<int?> getHighestSeenProtocolNumber() async {
    final prefs = await _init();
    await prefs.getInt(_HIGHEST_SEEN_PROTOCOL_NUMBER_KEY);
  }
}
