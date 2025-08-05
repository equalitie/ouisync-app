import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:result_type/result_type.dart' show Result, Success, Failure;

import '../../utils.dart' show DatabaseId;
import 'secure_storage.dart';

class FlutterSecure {
  FlutterSecure._();

  static final _storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  static Future<Result<Void, Error>> writeValue({
    required DatabaseId databaseId,
    required String password,
  }) async {
    try {
      await _storage.write(key: databaseId.toString(), value: password);
      return Success(Void());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<String?, Error>> readValue({
    required DatabaseId databaseId,
  }) async {
    try {
      return Success(await _storage.read(key: databaseId.toString()));
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<Void, Error>> deleteValue({
    required DatabaseId databaseId,
  }) async {
    try {
      await _storage.delete(key: databaseId.toString());
      return Success(Void());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<bool, Error>> exist({
    required DatabaseId databaseId,
  }) async {
    try {
      return Success(await _storage.containsKey(key: databaseId.toString()));
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }
}

AndroidOptions _getAndroidOptions() => const AndroidOptions(
  // TODO: the default value of this if `false` so we can't remove it yet. Ignoring the lint for now
  // but we should revisit when `flutter_secure_storage` gets bumped.
  //
  // ignore: deprecated_member_use
  encryptedSharedPreferences: true,
);
