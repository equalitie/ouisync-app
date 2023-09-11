import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage.dart';

class FlutterSecure {
  FlutterSecure._();

  static final _storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  static Future<SecureStorageResult> writeValue(
      {required String databaseId, required String password}) async {
    try {
      await _storage.write(key: databaseId, value: password);
    } on Exception catch (e, st) {
      return SecureStorageResult(value: null, exception: e, stackTrace: st);
    }

    return SecureStorageResult(value: null);
  }

  static Future<SecureStorageResult> readValue(
      {required String databaseId}) async {
    String? password;

    try {
      password = await _storage.read(key: databaseId);
    } on Exception catch (e, st) {
      return SecureStorageResult(value: null, exception: e, stackTrace: st);
    }

    return SecureStorageResult(value: password);
  }

  static Future<SecureStorageResult> deleteValue(
      {required String databaseId}) async {
    try {
      await _storage.delete(key: databaseId);
    } on Exception catch (e, st) {
      return SecureStorageResult(value: null, exception: e, stackTrace: st);
    }

    return SecureStorageResult(value: null);
  }
}

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);
