import 'package:biometric_storage/biometric_storage.dart';

import 'constants.dart';

class SecureStorage {
  static final BiometricStorage _storage = BiometricStorage();

  SecureStorage._();

  static Future<BiometricStorageFile> _getStorageFileForKey(
      String key, bool authenticationRequired) async {
    final initOptions =
        StorageFileInitOptions(authenticationRequired: authenticationRequired);

    return _storage.getStorage(key, options: initOptions);
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
    final authenticationRequired = _isAuthenticationRequired(authMode);

    try {
      final storageFile =
          await _getStorageFileForKey(databaseId, authenticationRequired);

      await storageFile.write(password);
    } on Exception catch (e) {
      return SecureStorageResult(value: null, exception: e);
    }

    return SecureStorageResult(value: null);
  }

  static Future<SecureStorageResult> getRepositoryPassword(
      {required String databaseId, required String authMode}) async {
    final authenticationRequired = _isAuthenticationRequired(authMode);

    String? password;

    try {
      final storageFile =
          await _getStorageFileForKey(databaseId, authenticationRequired);

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
    try {
      final storageFile =
          await _getStorageFileForKey(databaseId, authenticationRequired);

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
