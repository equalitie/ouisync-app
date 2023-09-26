import 'dart:io' show Platform;

import 'package:biometric_storage/biometric_storage.dart';
import 'package:result_type/result_type.dart';

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

  static Future<Result<Void, Error>> addRepositoryPassword(
      {required String databaseId,
      required String password,
      required AuthMode authMode}) async {
    final key = _getKey(databaseId, authMode);
    final authenticationRequired = _isAuthenticationRequired(authMode);

    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      await storageFile.write(password);
      return Success(Void());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<String?, Error>> getRepositoryPassword(
      {required String databaseId, required AuthMode authMode}) async {
    final key = _getKey(databaseId, authMode);
    final authenticationRequired = _isAuthenticationRequired(authMode);

    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      return Success(await storageFile.read());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }

  static Future<Result<Void, Error>> deleteRepositoryPassword(
      {required String databaseId,
      required AuthMode authMode,
      required bool authenticationRequired}) async {
    final key = _getKey(databaseId, authMode);
    try {
      final storageFile =
          await _getStorageFileForKey(key, authenticationRequired);

      await storageFile.delete();
      return Success(Void());
    } on Exception catch (e, st) {
      return Failure(Error(e, st));
    }
  }
}
