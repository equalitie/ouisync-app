import 'package:ouisync_app/app/utils/log.dart';

import '../utils/master_key.dart';
import 'local_secret.dart';

const _keys = (
  encryptedPassword: 'encryptedPassword',
  encryptedKey: 'encryptedKey',
  keyOrigin: 'keyOrigin',
  secureWithBiometrics: 'secureWithBiometrics',
);

sealed class AuthMode {
  Object? toJson();

  // May throw.
  static AuthMode fromJson(Object? data) =>
      AuthModeBlindOrManual.fromJson(data) ??
      AuthModePasswordStoredOnDevice.fromJson(data) ??
      AuthModeKeyStoredOnDevice.fromJson(data) ??
      _decodeError(data);

  LocalSecretMode get localSecretMode => switch (this) {
        AuthModeBlindOrManual() => LocalSecretMode.manual,
        AuthModeKeyStoredOnDevice(
          keyOrigin: SecretKeyOrigin.random,
          secureWithBiometrics: false
        ) =>
          LocalSecretMode.randomStored,
        AuthModeKeyStoredOnDevice(
          keyOrigin: SecretKeyOrigin.random,
          secureWithBiometrics: true
        ) =>
          LocalSecretMode.randomSecuredWithBiometrics,
        AuthModeKeyStoredOnDevice(
          keyOrigin: SecretKeyOrigin.manual,
          secureWithBiometrics: false
        ) =>
          LocalSecretMode.manualStored,
        AuthModeKeyStoredOnDevice(
          keyOrigin: SecretKeyOrigin.manual,
          secureWithBiometrics: true
        ) =>
          LocalSecretMode.manualSecuredWithBiometrics,
        AuthModePasswordStoredOnDevice(secureWithBiometrics: false) =>
          LocalSecretMode.manualStored,
        AuthModePasswordStoredOnDevice(secureWithBiometrics: true) =>
          LocalSecretMode.manualSecuredWithBiometrics,
      };
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
  final bool secureWithBiometrics;

  AuthModePasswordStoredOnDevice(
    this.encryptedPassword,
    this.secureWithBiometrics,
  );

  AuthModePasswordStoredOnDevice copyWith({
    String? encryptedPassword,
    bool? secureWithBiometrics,
  }) =>
      AuthModePasswordStoredOnDevice(
        encryptedPassword ?? this.encryptedPassword,
        secureWithBiometrics ?? this.secureWithBiometrics,
      );

  // May throw.
  Future<LocalPassword> getRepositoryPassword(MasterKey masterKey) async {
    final decrypted = await masterKey.decrypt(encryptedPassword);
    if (decrypted == null) throw AuthModeDecryptFailed;
    return LocalPassword(decrypted);
  }

  @override
  Object? toJson() => {
        _keys.encryptedPassword: encryptedPassword,
        _keys.secureWithBiometrics: secureWithBiometrics,
      };

  static AuthMode? fromJson(Object? data) {
    if (data is! Map) {
      return null;
    }

    final encryptedPassword = data[_keys.encryptedPassword];
    if (encryptedPassword == null) return null;

    final secureWithBiometrics = data[_keys.secureWithBiometrics];
    if (secureWithBiometrics == null) return null;

    return AuthModePasswordStoredOnDevice(
      encryptedPassword,
      secureWithBiometrics,
    );
  }
}

class AuthModeKeyStoredOnDevice extends AuthMode {
  final String encryptedKey;
  final bool secureWithBiometrics;
  final SecretKeyOrigin keyOrigin;

  AuthModeKeyStoredOnDevice({
    required this.encryptedKey,
    required this.keyOrigin,
    required this.secureWithBiometrics,
  });

  static Future<AuthModeKeyStoredOnDevice> encrypt(
    MasterKey masterKey,
    LocalSecretKey plainKey, {
    required SecretKeyOrigin keyOrigin,
    required bool secureWithBiometrics,
  }) async {
    final encryptedKey = await masterKey.encryptBytes(plainKey.bytes);

    return AuthModeKeyStoredOnDevice(
      encryptedKey: encryptedKey,
      keyOrigin: keyOrigin,
      secureWithBiometrics: secureWithBiometrics,
    );
  }

  AuthModeKeyStoredOnDevice copyWith({
    String? encryptedKey,
    SecretKeyOrigin? keyOrigin,
    bool? secureWithBiometrics,
  }) =>
      AuthModeKeyStoredOnDevice(
        encryptedKey: encryptedKey ?? this.encryptedKey,
        keyOrigin: keyOrigin ?? this.keyOrigin,
        secureWithBiometrics: secureWithBiometrics ?? this.secureWithBiometrics,
      );

  // May throw.
  Future<LocalSecretKey> decryptKey(MasterKey masterKey) async {
    final decrypted = await masterKey.decryptBytes(encryptedKey);
    if (decrypted == null) throw AuthModeDecryptFailed();
    return LocalSecretKey(decrypted);
  }

  @override
  Object? toJson() => {
        _keys.encryptedKey: encryptedKey,
        _keys.keyOrigin: keyOrigin.toJson(),
        _keys.secureWithBiometrics: secureWithBiometrics,
      };

  static AuthMode? fromJson(Object? data) {
    if (data is! Map) {
      return null;
    }

    final encryptedKey = data[_keys.encryptedKey];
    if (encryptedKey == null) return null;

    final keyOrigin = SecretKeyOrigin.fromJson(data[_keys.keyOrigin]);
    if (keyOrigin == null) return null;

    final secureWithBiometrics = data[_keys.secureWithBiometrics];
    if (secureWithBiometrics == null) return null;

    return AuthModeKeyStoredOnDevice(
      encryptedKey: encryptedKey,
      keyOrigin: keyOrigin,
      secureWithBiometrics: secureWithBiometrics,
    );
  }

  @override
  String toString() =>
      '$runtimeType(keyOrigin: $keyOrigin, secureWithBiometrics: $secureWithBiometrics)';
}

/// How is the local secret key obtained
enum SecretKeyOrigin {
  /// The key is derived from a password provided by the user.
  manual,

  /// The key is randomly generated.
  random,
  ;

  Object toJson() => name;

  static SecretKeyOrigin? fromJson(Object? data) {
    if (data == manual.name) {
      return manual;
    }

    if (data == random.name) {
      return random;
    }

    return null;
  }
}

enum SecretKeyStore {
  notStored,
  stored,
  securedWithBiometrics,
  ;

  bool get isStored => switch (this) {
        notStored => false,
        stored || securedWithBiometrics => true,
      };

  bool get isSecuredWithBiometrics => switch (this) {
        securedWithBiometrics => true,
        notStored || stored => false,
      };
}

/// How is the local secret key obtained and stored
enum LocalSecretMode {
  /// Derived from a user provided password, not stored in the secure storage
  manual,

  /// Derived from a user provided password, stored in the secure storage
  manualStored,

  /// Derived from a user provided password, stored in the secure storage and requires biometric
  /// check to retrieve
  manualSecuredWithBiometrics,

  /// Randomly generated, stored in the secure storage
  randomStored,

  /// Randomly generated, stored in the secure storage and requires biometric check to retrieve
  randomSecuredWithBiometrics,
  ;

  SecretKeyOrigin get origin => switch (this) {
        manual ||
        manualStored ||
        manualSecuredWithBiometrics =>
          SecretKeyOrigin.manual,
        randomStored || randomSecuredWithBiometrics => SecretKeyOrigin.random,
      };

  SecretKeyStore get store => switch (this) {
        manual => SecretKeyStore.notStored,
        manualStored || randomStored => SecretKeyStore.stored,
        LocalSecretMode.manualSecuredWithBiometrics ||
        LocalSecretMode.randomSecuredWithBiometrics =>
          SecretKeyStore.securedWithBiometrics,
      };
}

/// Parameters to compute local secret and auth mode.
sealed class LocalSecretInput {
  LocalSecretMode get mode;
}

class LocalSecretManual extends LocalSecretInput {
  LocalSecretManual({required this.password, required this.store});

  final LocalPassword password;
  final SecretKeyStore store;

  @override
  LocalSecretMode get mode => switch (store) {
        SecretKeyStore.notStored => LocalSecretMode.manual,
        SecretKeyStore.stored => LocalSecretMode.manualStored,
        SecretKeyStore.securedWithBiometrics =>
          LocalSecretMode.manualSecuredWithBiometrics,
      };
}

class LocalSecretRandom extends LocalSecretInput {
  LocalSecretRandom({this.secureWithBiometrics = false});

  final bool secureWithBiometrics;

  @override
  LocalSecretMode get mode => secureWithBiometrics
      ? LocalSecretMode.randomSecuredWithBiometrics
      : LocalSecretMode.randomStored;
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

AuthMode _decodeError(Object? data) {
  staticLogger<AuthMode>().error('invalid auth mode data: `$data`');
  throw AuthModeParseFailed();
}
