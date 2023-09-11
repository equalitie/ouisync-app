import 'package:local_auth/local_auth.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';
import 'storage.dart';

class SecureStorage with AppLogger {
  final String databaseId;
  SecureStorage({required this.databaseId});

  Future<String?> saveOrUpdatePassword({required String value}) async {
    final result =
        await FlutterSecure.writeValue(databaseId: databaseId, password: value);

    if (result.exception != null) {
      loggy.error('Saving repository password to flutter_secure_storage failed',
          result.exception, result.stackTrace);

      return null;
    }

    return value;
  }

  Future<String?> tryGetPassword({required AuthMode authMode}) async {
    if (authMode == AuthMode.manual) return null;

    return authMode == AuthMode.secured
        ? _readFlutterSecureStorage(databaseId)
        : _getValueAndMigrateFromBiometricStorage(databaseId, authMode);
  }

  Future<bool> deletePassword() async {
    final result = await FlutterSecure.deleteValue(databaseId: databaseId);

    if (result.exception != null) {
      loggy.error('Deleting repository password from secure storage failed',
          result.exception, result.stackTrace);

      return false;
    }

    return true;
  }

  Future<String?> _readFlutterSecureStorage(String databaseId) async {
    final result = await FlutterSecure.readValue(databaseId: databaseId);

    if (result.exception != null) {
      loggy.error(
          'Getting repository password from flutter_secure_storage failed',
          result.exception,
          result.stackTrace);

      return null;
    }

    return result.value ?? '';
  }

  /// Runs once per repository (if needed): before adding to the app the
  /// possibility to create a repository without a local password, any entry
  /// to the secure storage (biometric_storage) required biometric validation
  /// (authenticationRequired=true, by default).
  ///
  /// With the option of not having a local password, we now save the password,
  /// for both this option and biometrics, in the secure storage, and only in
  /// the latest case we require biometric validation, using the Dart package
  /// local_auth, instead of the biometric_storage built in validation.
  ///
  /// Any repo that doesn't have this setting is considered from a version
  /// before this implementation, and we need to determine the value for this
  /// setting right after the update, on the first unlocking.
  ///
  /// Trying to get the password from the secure storage using the built in
  /// biometric validation can tell us this:
  ///
  /// IF securePassword != null
  ///   The repo password exist and it was secured using biometrics. (version1)
  /// ELSE
  ///   The repo password doesn't exist and it was manually input by the user.
  ///
  /// (If the password is empty, something wrong happened in the previous
  /// version of the app saving its value and it is considered non existent
  /// in the secure storage, this is, not secured with biometrics).
  ///
  /// Now we have decided to moved on from biometric_storage and use
  /// flutter_secure_storage.
  ///
  /// To achieve this we still use the old transformation from AuthMode.version1
  /// to AuthMode.version2, but instead of going throught AuthMode.version2, we
  /// just go from either version to AuthMode.secure, which uses the new plugin.
  Future<String?> _getValueAndMigrateFromBiometricStorage(
      String databaseId, AuthMode authMode) async {
    if (authMode == AuthMode.version2) {
      final auth = LocalAuthentication();

      final authorized = await auth.authenticate(
          localizedReason: S.current.messageAccessingSecureStorage);

      if (authorized == false) {
        return null;
      }
    }

    final value =
        await _readBiometricStorage(databaseId: databaseId, authMode: authMode);

    if (value != null) {
      await _migrateToSecureAuthMode(databaseId, value, authMode);
    }

    return value;
  }

  Future<String?> _readBiometricStorage(
      {required String databaseId, required AuthMode authMode}) async {
    final secureStorageResult = await BiometricSecure.getRepositoryPassword(
        databaseId: databaseId, authMode: authMode);

    if (secureStorageResult.exception != null) {
      loggy.error('Getting repository password from biometric_storage failed',
          secureStorageResult.exception, secureStorageResult.stackTrace);

      return null;
    }

    return secureStorageResult.value ?? '';
  }

  Future<void> _migrateToSecureAuthMode(
      String databaseId, String value, AuthMode authMode) async {
    final saveResult =
        await FlutterSecure.writeValue(databaseId: databaseId, password: value);

    if (saveResult.exception != null) {
      loggy.error('', saveResult.exception, saveResult.stackTrace);
      return;
    }

    final deleteOldResult = await BiometricSecure.deleteRepositoryPassword(
        databaseId: databaseId,
        authMode: authMode,
        authenticationRequired: false);

    if (deleteOldResult.exception != null) {
      loggy.error(
          'Adding repository to latest storage was successful, but removal from legacy secure storage failed: It was ${authMode.name}',
          deleteOldResult.exception,
          deleteOldResult.stackTrace);
    }

    loggy.info(
        'Migrating repository in legacy secure storage to latest storage was successful: It was ${authMode.name}');
  }
}

class SecureStorageResult {
  SecureStorageResult({required this.value, this.exception, this.stackTrace});

  final String? value;
  final Exception? exception;
  final StackTrace? stackTrace;
}
