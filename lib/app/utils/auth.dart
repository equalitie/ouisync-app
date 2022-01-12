import 'package:crypt/crypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth {
  Auth._();

  static FlutterSecureStorage storage = FlutterSecureStorage();

  static void setPassword(String uid, String? password) {
    storage.write(key: uid, value: password, aOptions: AndroidOptions(encryptedSharedPreferences: true));
  }

  static Future<String?> getPassword(String uid) async {
    return await storage.read(key: uid, aOptions: AndroidOptions(encryptedSharedPreferences: true)) ?? '';
  }

  static Future<bool> checkPassword(String uid, String password) async {
    String? storedHashedPassword = await storage.read(key: uid);
    if (storedHashedPassword == null) { // key doesn't exist in the storage
      return false;
    }

    return Future.value(Crypt(storedHashedPassword).match(password));
  }
}