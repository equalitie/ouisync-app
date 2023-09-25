import 'dart:io' show Platform;

import 'package:biometric_storage/biometric_storage.dart';

import '../utils/constants.dart';
import 'storage.dart';

BiometricStorage _chooseStorageByPlatform() {
  if (Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isLinux) {
    return MethodChannelBiometricStorage();
  } else {
    return Win32BiometricStoragePlugin() as BiometricStorage;
  }
}

class BiometricSecure {
  static final BiometricStorage _storage = _chooseStorageByPlatform();

  BiometricSecure._();

  static Future<BiometricStorageFile> _getStorageFileForKey(
      String key, bool authenticationRequired) async {
    final initOptions =
        StorageFileInitOptions(authenticationRequired: authenticationRequired);

    return _storage.getStorage(key, options: initOptions);
  }

  static _getKey(String databaseId, AuthMode authMode) {
    if (authMode == AuthMode.version2) {
      return '$databaseId-v2';
    }

    return databaseId;
  }

  static _isAuthenticationRequired(AuthMode authMode) {
    if (authMode == AuthMode.version1) {
      return true;
    }

    return false;
  }

  static Future<SecureStorageResult> addRepositoryPassword(
      {required String databaseId,
      required String password,
      required AuthMode authMode}) async {
    final key = _getKey(databaseId, authMode);
    final authenticationRequired = _isAuthenticationRequired(authMode);

    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      await storageFile.write(password);
    } on Exception catch (e, st) {
      return SecureStorageResult(value: null, exception: e, stackTrace: st);
    }

    return SecureStorageResult(value: null);
  }

  static Future<SecureStorageResult> getRepositoryPassword(
      {required String databaseId, required AuthMode authMode}) async {
    final key = _getKey(databaseId, authMode);
    final authenticationRequired = _isAuthenticationRequired(authMode);

    String? password;

    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      password = await storageFile.read();
    } on Exception catch (e, st) {
      return SecureStorageResult(value: null, exception: e, stackTrace: st);
    }

    return SecureStorageResult(value: password);
  }

  static Future<SecureStorageResult> deleteRepositoryPassword(
      {required String databaseId,
      required AuthMode authMode,
      required bool authenticationRequired}) async {
    final key = _getKey(databaseId, authMode);
    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      await storageFile.delete();
    } on Exception catch (e, st) {
      return SecureStorageResult(value: null, exception: e, stackTrace: st);
    }

    return SecureStorageResult(value: null);
  }
}