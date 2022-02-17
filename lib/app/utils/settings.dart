import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

class Settings {
  static SharedPreferences? _preferences;

  static Future<void> _init() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
  }

  static Future<void> initSettings(
    String appDir,
    String repositoriesDir,
  ) async {
    if (_preferences == null) {
      await _init();
    }

    await _preferences!.setString(Constants.appDirKey, appDir);
    await _preferences!.setString(Constants.repositoriesDirKey, repositoriesDir);
  }

  static dynamic readSetting(String key) async {
    if (_preferences == null) {
      await _init();
    }

    if (_preferences!.containsKey(key)) {
      return _preferences!.get(key);
    }

    return null;
  }

  static Future<bool> saveSetting(String key, value) async {
    if (_preferences == null) {
      await _init();
    }

    switch (value.runtimeType) {
      case bool:
        print('Saving setting $key<${value.runtimeType}>: $value');
        await _preferences!.setBool(key, value);

        break;

      case double:
        print('Saving setting $key<${value.runtimeType}>: $value');
        await _preferences!.setDouble(key, value);
        
        break;

      case int:
        print('Saving setting $key<${value.runtimeType}>: $value');
        await _preferences!.setInt(key, value);
        
        break;

      case String:
        print('Saving setting $key<${value.runtimeType}>: $value');
        await _preferences!.setString(key, value);

        break;

      case List:
        print('Saving setting $key<${value.runtimeType}>: $value');
        await _preferences!.setStringList(key, value);

        break;
      
      default:
        print('No supported type for setting $key<${value.runtimeType}>: $value');
        return false;
    }

    return true;
  }
}
