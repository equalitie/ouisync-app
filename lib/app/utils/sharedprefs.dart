import 'package:ouisync_app/app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  // List<String> get userRepos =>  _sharedPrefs.getStringList(sharedPrefereceReposKey) ?? [];

  // set userRepos (List<String> userRepos) {
  //   _sharedPrefs.setStringList(sharedPrefereceReposKey, userRepos);
  // }
}