import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:meta/meta.dart'; // for `@visibleForTesting`
import 'dart:typed_data';
import 'dart:convert';
import 'cipher.dart' as cipher;

class MasterKey {
  static const String _masterKey = 'masterKey';
  static final _mutex = Mutex();

  final cipher.SecretKey secretKey;

  MasterKey._(this.secretKey);

  /// Load the master key from the secure storage. Generate a new one if not stored yet.
  static Future<MasterKey> init() async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

    // Ensure nothing else tries to initialize the MasterKey concurrently or data
    // loss could happen.
    await _mutex.acquire();

    try {
      var masterKeyBase64 = await storage.read(key: _masterKey);

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
}

// I think we need the `encryptedSharedPreferense: true` option on Android,
// otherwise we the stored values don't seem to be preserved after app restart.
AndroidOptions _getAndroidOptions() => const AndroidOptions(
  // TODO: the default value of this if `false` so we can't remove it yet. Ignoring the lint for now
  // but we should revisit when `flutter_secure_storage` gets bumped.
  //
  // ignore: deprecated_member_use
  encryptedSharedPreferences: true,
);
