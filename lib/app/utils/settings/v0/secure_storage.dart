import 'flutter_secure.dart';
import 'biometric_secure.dart';
import 'v0.dart';
import '../../../utils/platform/platform.dart';
import '../../../utils/utils.dart';

class SecureStorage with AppLogger {
  final DatabaseId databaseId;

  SecureStorage({required this.databaseId});

  Future<String?> saveOrUpdatePassword({required String value}) async {
    final result = await FlutterSecure.writeValue(
      databaseId: databaseId,
      password: value,
    );

    if (result.isFailure) {
      loggy.error(
        'Saving repository password to flutter_secure_storage failed',
        result.failure.exception,
        result.failure.stackTrace,
      );

      return null;
    }

    return value;
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
  Future<String?> tryGetPassword({required AuthMode authMode}) async {
    if (authMode == AuthMode.manual) return null;

    final password = await _readFlutterSecureStorage(databaseId, authMode);

    if (password != null) {
      return password;
    }

    // Try to migrate the password from the legacy `biometric_storage` plugin.
    if (PlatformValues.isMobileDevice && authMode == AuthMode.version2) {
      final authorized = await _validateBiometrics();
      if (authorized == false) {
        return null;
      }
    }

    final value = await _readLegacyBiometricStorage(
      databaseId: databaseId,
      authMode: authMode,
    );

    if (value == null) {
      return null;
    }

    await _migrateToSecureAuthMode(databaseId, value, authMode);

    return value;
  }

  Future<bool> deletePassword() async {
    final result = await FlutterSecure.deleteValue(databaseId: databaseId);

    if (result.isFailure) {
      loggy.error(
        'Deleting repository password from secure storage failed',
        result.failure.exception,
        result.failure.stackTrace,
      );

      return false;
    }

    return true;
  }

  /////////////////////////////////

  Future<bool> _validateBiometrics() async {
    // No longer necessary when we have newer version of settings.
    return true;
    //try {
    //  return await SecurityValidations.validateBiometrics();
    //} on Exception catch (e, st) {
    //  loggy.app('Biometric authentication (local_auth) failed', e, st);
    //  return false;
    //}
  }

  Future<String?> _readFlutterSecureStorage(
    DatabaseId databaseId,
    AuthMode authMode,
  ) async {
    if (PlatformValues.isMobileDevice &&
        [AuthMode.version1, AuthMode.version2].contains(authMode)) {
      final authorized = await _validateBiometrics();
      if (authorized == false) {
        return null;
      }
    }

    final result = await FlutterSecure.readValue(databaseId: databaseId);
    if (result.isFailure) {
      loggy.error(
        'Getting repository password from flutter_secure_storage failed',
        result.failure.exception,
        result.failure.stackTrace,
      );

      return null;
    }

    return result.success;
  }

  Future<String?> _readLegacyBiometricStorage({
    required DatabaseId databaseId,
    required AuthMode authMode,
  }) async {
    final result = await BiometricSecure.getRepositoryPassword(
      databaseId: databaseId,
      authMode: authMode,
    );

    if (result.isFailure) {
      loggy.error(
        'Getting repository password from biometric_storage failed',
        result.failure.exception,
        result.failure.stackTrace,
      );

      return null;
    }

    return result.success;
  }

  Future<void> _migrateToSecureAuthMode(
    DatabaseId databaseId,
    String password,
    AuthMode authMode,
  ) async {
    final result = await FlutterSecure.writeValue(
      databaseId: databaseId,
      password: password,
    );

    if (result.isFailure) {
      loggy.error('', result.failure.exception, result.failure.stackTrace);
      return;
    }

    final deleteOldResult = await BiometricSecure.deleteRepositoryPassword(
      databaseId: databaseId,
      authMode: authMode,
      authenticationRequired: false,
    );

    if (deleteOldResult.isFailure) {
      loggy.error(
        'Adding repository to latest storage was successful, but removal from legacy secure storage failed: It was ${authMode.name}',
        deleteOldResult.failure.exception,
        deleteOldResult.failure.stackTrace,
      );
    }

    loggy.info(
      'Migrating repository in legacy secure storage to latest storage was successful: It was ${authMode.name}',
    );
  }
}

class Void {}

class Error implements Exception {
  Error(this.exception, this.stackTrace);
  final Exception exception;
  final StackTrace stackTrace;
}
