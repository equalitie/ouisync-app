import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:result_type/result_type.dart' show Result, Success, Failure;

import '../../native.dart';
import '../../utils.dart' show DatabaseId;
import 'secure_storage.dart';

class FlutterSecure {
  FlutterSecure._();

  // Don't let the plugin delete the stored values when it fails to decrypt them (the default).
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: false),
  );

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
      final key = databaseId.toString();
      return Success(
        await _storage.read(key: key) ?? await _readLegacy(key),
      );
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<Void, Error>> deleteValue({
    required DatabaseId databaseId,
  }) async {
    try {
      final key = databaseId.toString();
      await _storage.delete(key: key);
      await _deleteLegacy(key);
      return Success(Void());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<bool, Error>> exist({
    required DatabaseId databaseId,
  }) async {
    try {
      final key = databaseId.toString();
      return Success(
        await _storage.containsKey(key: key) || await _readLegacy(key) != null,
      );
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  // On Android, Ouisync 0.9.4 and older stored the values using `flutter_secure_storage`
  // 10.0.0-beta.4, in a format newer versions of the plugin can't read. See `MasterKey`.
  static Future<String?> _readLegacy(String key) async =>
      Platform.isAndroid ? Native.instance.readLegacySecureStorage(key) : null;

  static Future<void> _deleteLegacy(String key) async {
    if (Platform.isAndroid) {
      await Native.instance.deleteLegacySecureStorage(key);
    }
  }
}
