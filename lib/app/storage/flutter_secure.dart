import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:result_type/result_type.dart';

import 'storage.dart';

class FlutterSecure {
  FlutterSecure._();

  static final _storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  static Future<Result<Void, Error>> writeValue(
      {required String databaseId, required String password}) async {
    try {
      await _storage.write(key: databaseId, value: password);
      return Success(Void());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<String?, Error>> readValue(
      {required String databaseId}) async {
    try {
      return Success(await _storage.read(key: databaseId));
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<Void, Error>> deleteValue(
      {required String databaseId}) async {
    try {
      await _storage.delete(key: databaseId);
      return Success(Void());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<bool, Error>> exist({required String databaseId}) async {
    try {
      return Success(await _storage.containsKey(key: databaseId));
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }
}

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);
