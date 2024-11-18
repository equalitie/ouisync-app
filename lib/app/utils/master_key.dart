import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:meta/meta.dart'; // for `@visibleForTesting`
import 'dart:typed_data';
import 'dart:convert';
import './cipher.dart' as cipher;

class MasterKey {
  static const String _masterKey = 'masterKey';
  static final _mutex = Mutex();

  final cipher.Cipher _cipher;

  MasterKey._(cipher.SecretKey masterKey) : _cipher = cipher.Cipher(masterKey);

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
        final algo = cipher.Cipher.newAlgorithm();
        final key = cipher.Cipher.randomSecretKey(algo);
        masterKeyBase64 = base64.encode(key.bytes);
        await storage.write(key: _masterKey, value: masterKeyBase64);
      }

      return MasterKey._(cipher.SecretKey(base64.decode(masterKeyBase64)));
    } finally {
      _mutex.release();
    }
  }

  /// Generate a throwaway master key. Useful for testing.
  static MasterKey random() {
    final algo = cipher.Cipher.newAlgorithm();
    final key = cipher.Cipher.randomSecretKey(algo);
    return MasterKey._(key);
  }

  Future<String> encrypt(String plainText) async {
    return await _cipher.encrypt(plainText);
  }

  Future<String> encryptBytes(Uint8List plainText) async {
    return await _cipher.encryptBytes(plainText);
  }

  // Returns `null` if decryption fails.
  Future<String?> decrypt(String encrypted) async {
    return await _cipher.decrypt(encrypted);
  }

  // Returns `null` if decryption fails.
  Future<Uint8List?> decryptBytes(String encrypted) async {
    return await _cipher.decryptBytes(encrypted);
  }

  @visibleForTesting
  static MasterKey initWithKey(String keyBase64) =>
      MasterKey._(cipher.SecretKey(base64.decode(keyBase64)));

  @visibleForTesting
  static String generateKey() {
    final algo = cipher.Cipher.newAlgorithm();
    return base64.encode(cipher.Cipher.randomSecretKey(algo).bytes);
  }
}

// I think we need the `encryptedSharedPreferense: true` option on Android,
// otherwise we the stored values don't seem to be preserved after app restart.
AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);
