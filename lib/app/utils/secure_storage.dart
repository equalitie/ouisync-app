import 'package:biometric_storage/biometric_storage.dart';
import 'dart:io' show Platform;

import 'constants.dart';

BiometricStorage _chooseStorageByPlatform() {
  if (Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isLinux) {
    return MethodChannelBiometricStorage();
  } else {
    return Win32BiometricStoragePlugin();
  }
}

class SecureStorage {
  static final BiometricStorage _storage = _chooseStorageByPlatform();

  SecureStorage._();

  static Future<BiometricStorageFile> _getStorageFileForKey(
      String key, bool authenticationRequired) async {
    final initOptions =
        StorageFileInitOptions(authenticationRequired: authenticationRequired);

    return _storage.getStorage(key, options: initOptions);
  }

  static _getKey(String databaseId, String authMode) {
    if (authMode == Constants.authModeVersion2) {
      return '$databaseId-v2';
    }

    return databaseId;
  }

  static _isAuthenticationRequired(String authMode) {
    if (authMode == Constants.authModeVersion1) {
      return true;
    }

    return false;
  }

  static Future<SecureStorageResult> addRepositoryPassword(
      {required String databaseId,
      required String password,
      required String authMode}) async {
    final key = _getKey(databaseId, authMode);
    final authenticationRequired = _isAuthenticationRequired(authMode);

    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      await storageFile.write(password);
    } on Exception catch (e) {
      return SecureStorageResult(value: null, exception: e);
    }

    return SecureStorageResult(value: null);
  }

  static Future<SecureStorageResult> getRepositoryPassword(
      {required String databaseId, required String authMode}) async {
    final key = _getKey(databaseId, authMode);
    final authenticationRequired = _isAuthenticationRequired(authMode);

    String? password;

    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      password = await storageFile.read();
    } on Exception catch (e) {
      return SecureStorageResult(value: null, exception: e);
    }

    return SecureStorageResult(value: password);
  }

  static Future<SecureStorageResult> deleteRepositoryPassword(
      {required String databaseId,
      required String authMode,
      required bool authenticationRequired}) async {
    final key = _getKey(databaseId, authMode);
    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      await storageFile.delete();
    } on Exception catch (e) {
      return SecureStorageResult(value: null, exception: e);
    }

    return SecureStorageResult(value: null);
  }
}

class SecureStorageResult {
  SecureStorageResult({required this.value, this.exception});

  final String? value;
  final Exception? exception;
}
