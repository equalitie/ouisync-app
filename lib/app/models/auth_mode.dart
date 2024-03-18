import 'package:ouisync_app/app/models/models.dart';

import '../utils/master_key.dart';

const _encryptedPasswordKey = 'encryptedPassword';
const _encryptedKeyKey = 'encryptedKey';
const _confirmWithBiometricsKey = 'confirmWithBiometrics';

sealed class AuthMode {
  Object? toJson();

  // May throw.
  static AuthMode fromJson(Object? data) =>
      AuthModeBlindOrManual.fromJson(data) ??
      AuthModePasswordStoredOnDevice.fromJson(data) ??
      AuthModeKeyStoredOnDevice.fromJson(data) ??
      (throw AuthModeParseFailed);

  bool get hasLocalSecret => switch (this) {
        AuthModePasswordStoredOnDevice() || AuthModeKeyStoredOnDevice() => true,
        AuthModeBlindOrManual() => false,
      };

  bool get shouldCheckBiometricsBeforeUnlock => switch (this) {
        AuthModePasswordStoredOnDevice(confirmWithBiometrics: final check) ||
        AuthModeKeyStoredOnDevice(confirmWithBiometrics: final check) =>
          check,
        AuthModeBlindOrManual() => false,
      };

  PasswordMode get passwordMode {
    if (hasLocalSecret) {
      if (shouldCheckBiometricsBeforeUnlock) {
        return PasswordMode.bio;
      } else {
        return PasswordMode.none;
      }
    } else {
      return PasswordMode.manual;
    }
  }
}

class AuthModeBlindOrManual extends AuthMode {
  @override
  Object? toJson() => null;

  static AuthMode? fromJson(dynamic data) =>
      data == null ? AuthModeBlindOrManual() : null;
}

// This is a legacy AuthMode, we used to generate high entropy (24 characters:
// upper and lower case letters, numbers, special chars) passwords and store
// those encrypted.  Because those passwords were high entropy, the fact that
// we did not run them through a password hashing function before encryption
// perhaps was not such a tragedy. And they still need to go through Argon2
// when passed to Ouisync library. Still, LocalSecretKey has much higher
// entropy (256-bits) and so only that is now used.  TODO: Should we force
// reset existing repos that use this legacy auth mode to use secret keys?
class AuthModePasswordStoredOnDevice extends AuthMode {
  final String encryptedPassword;
  final bool confirmWithBiometrics;

  AuthModePasswordStoredOnDevice(
    this.encryptedPassword,
    this.confirmWithBiometrics,
  );

  AuthModePasswordStoredOnDevice copyWith({
    String? encryptedPassword,
    bool? confirmWithBiometrics,
  }) =>
      AuthModePasswordStoredOnDevice(
        encryptedPassword ?? this.encryptedPassword,
        confirmWithBiometrics ?? this.confirmWithBiometrics,
      );

  // May throw.
  Future<LocalPassword> getRepositoryPassword(MasterKey masterKey) async {
    final decrypted = await masterKey.decrypt(encryptedPassword);
    if (decrypted == null) throw AuthModeDecryptFailed;
    return LocalPassword(decrypted);
  }

  @override
  Object? toJson() => {
        _encryptedPasswordKey: encryptedPassword,
        _confirmWithBiometricsKey: confirmWithBiometrics,
      };

  static AuthMode? fromJson(Object? data) {
    if (data is! Map) {
      return null;
    }

    final encryptedPassword = data[_encryptedPasswordKey];
    if (encryptedPassword == null) return null;

    final confirmWithBiometrics = data[_confirmWithBiometricsKey];
    if (confirmWithBiometrics == null) return null;

    return AuthModePasswordStoredOnDevice(
      encryptedPassword,
      confirmWithBiometrics,
    );
  }
}

class AuthModeKeyStoredOnDevice extends AuthMode {
  final String encryptedKey;
  final bool confirmWithBiometrics;

  AuthModeKeyStoredOnDevice(this.encryptedKey, this.confirmWithBiometrics);

  static Future<AuthModeKeyStoredOnDevice> encrypt(
    MasterKey masterKey,
    LocalSecretKey plainKey, {
    required bool confirmWithBiometrics,
  }) async {
    final encryptedKey = await masterKey.encryptBytes(plainKey.bytes);
    return AuthModeKeyStoredOnDevice(encryptedKey, confirmWithBiometrics);
  }

  AuthModeKeyStoredOnDevice copyWith({
    String? encryptedKey,
    bool? confirmWithBiometrics,
  }) =>
      AuthModeKeyStoredOnDevice(
        encryptedKey ?? this.encryptedKey,
        confirmWithBiometrics ?? this.confirmWithBiometrics,
      );

  // May throw.
  Future<LocalSecretKey> getRepositoryPassword(MasterKey masterKey) async {
    final decrypted = await masterKey.decryptBytes(encryptedKey);
    if (decrypted == null) throw AuthModeDecryptFailed();
    return LocalSecretKey(decrypted);
  }

  @override
  Object? toJson() => {
        _encryptedKeyKey: encryptedKey,
        _confirmWithBiometricsKey: confirmWithBiometrics,
      };

  static AuthMode? fromJson(Object? data) {
    if (data is! Map) {
      return null;
    }

    final encryptedKey = data[_encryptedKeyKey];
    if (encryptedKey == null) return null;

    final confirmWithBiometrics = data[_confirmWithBiometricsKey];
    if (confirmWithBiometrics == null) return null;

    return AuthModeKeyStoredOnDevice(encryptedKey, confirmWithBiometrics);
  }
}

sealed class AuthModeException implements Exception {}

class AuthModeParseFailed extends AuthModeException {
  @override
  String toString() => 'failed to parse auth mode';
}

class AuthModeDecryptFailed extends AuthModeException {
  @override
  String toString() => 'failed to decrypt local secret';
}
