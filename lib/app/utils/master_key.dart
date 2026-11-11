import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:meta/meta.dart'; // for `@visibleForTesting`

import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:convert';

import 'cipher.dart' as cipher;
import 'log.dart' as log;
import 'native.dart';

class MasterKey {
  static const String _masterKey = 'masterKey';
  static final _mutex = Mutex();
  static final _logger = log.named('MasterKey');

  final cipher.SecretKey secretKey;

  MasterKey._(this.secretKey);

  /// Load the master key from the secure storage. Generate a new one if not stored yet.
  static Future<MasterKey> init() async {
    final storage = FlutterSecureStorage(
      aOptions: _getAndroidOptions(),
      mOptions: _getMacOsOptions(),
    );

    // Ensure nothing else tries to initialize the MasterKey concurrently or data
    // loss could happen.
    await _mutex.acquire();

    try {
      var masterKeyBase64 =
          await _migrateLegacyKey(storage) ??
          await storage.read(key: _masterKey);

      if (masterKeyBase64 == null) {
        // No master password was generated yet, generate one now.
        final masterKey = cipher.randomSecretKey();
        masterKeyBase64 = base64.encode(masterKey.bytes);
        await storage.write(key: _masterKey, value: masterKeyBase64);
      }

      return MasterKey._(cipher.SecretKey(base64.decode(masterKeyBase64)));
    } finally {
      _mutex.release();
    }
  }

  /// Generate a throwaway master key. Useful for testing.
  static MasterKey random() => MasterKey._(cipher.randomSecretKey());

  Future<Uint8List> encrypt(Uint8List plainText) =>
      cipher.encrypt(secretKey, plainText);

  // Returns `null` if decryption fails.
  Future<Uint8List?> decrypt(Uint8List encrypted) async {
    return await cipher.decrypt(secretKey, encrypted);
  }

  @visibleForTesting
  static MasterKey initWithKey(String keyBase64) =>
      MasterKey._(cipher.SecretKey(base64.decode(keyBase64)));

  @visibleForTesting
  static String generateKey() => base64.encode(cipher.randomSecretKey().bytes);

  /// On Android, Ouisync 0.9.4 and older stored the master key using `flutter_secure_storage`
  /// 10.0.0-beta.4, in a format newer versions of the plugin can't read. Moves such key to the
  /// current storage and returns it, or returns `null` if there is none.
  ///
  /// The legacy key takes precedence over a key already in the current storage. Such key can only
  /// come from a pre-release build which generated a new key because it couldn't read the legacy
  /// one, and the repositories created before it need the legacy key.
  static Future<String?> _migrateLegacyKey(FlutterSecureStorage storage) async {
    if (!Platform.isAndroid) {
      return null;
    }

    final String? legacyKey;

    try {
      legacyKey = await Native.instance.readLegacySecureStorage(_masterKey);
    } catch (e, st) {
      // Don't generate a new key, the repositories would become inaccessible. The legacy key is
      // still stored and can possibly be recovered by a future version.
      _logger.error('failed to read the legacy master key:', e, st);
      throw MasterKeyUnreadable(e);
    }

    if (legacyKey == null) {
      return null;
    }

    _logger.info('migrating the legacy master key');

    await storage.write(key: _masterKey, value: legacyKey);

    // Delete the legacy key only once the new storage is known to hold it.
    if (await storage.read(key: _masterKey) != legacyKey) {
      _logger.error('failed to migrate the legacy master key: read back mismatch');
      throw MasterKeyUnreadable('legacy master key migration failed');
    }

    try {
      await Native.instance.deleteLegacySecureStorage(_masterKey);
    } catch (e, st) {
      // Not fatal: the next start migrates the same key again.
      _logger.error('failed to delete the legacy master key:', e, st);
    }

    return legacyKey;
  }
}

/// Thrown when the master key exists but can't be read. Generating a new key instead would make
/// all repositories whose secret is stored on the device inaccessible.
class MasterKeyUnreadable implements Exception {
  MasterKeyUnreadable(this.cause);

  final Object cause;

  @override
  String toString() => 'MasterKeyUnreadable($cause)';
}

// Don't let the plugin delete the stored values when it fails to decrypt them (the default).
// Losing the master key makes all repositories whose secret is stored on the device inaccessible.
AndroidOptions _getAndroidOptions() => AndroidOptions(resetOnError: false);

// On macOS the app is sandboxed with a keychain-access-group entitlement, so use the data
// protection keychain (entitlement-based, no interactive prompt). `first_unlock` accessibility
// avoids the "interaction not allowed" (-25308) failure seen when writing during early launch.
MacOsOptions _getMacOsOptions() =>
    const MacOsOptions(accessibility: KeychainAccessibility.first_unlock);
