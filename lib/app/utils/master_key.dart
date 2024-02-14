import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:mutex/mutex.dart';
import 'package:meta/meta.dart'; // for `@visibleForTesting`
import 'dart:typed_data';

class MasterKey {
  static const String _masterKey = 'masterKey';
  static const int _keyLengthInBytes = 32; // For Salsa20
  static const int _ivLengthInBytes = 8; // For Salsa20

  final Encrypter _encrypter;

  MasterKey._(Key masterKey) : _encrypter = Encrypter(Salsa20(masterKey));

  static Future<MasterKey> init() async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

    // Ensure nothing else tries to initialize the MasterKey concurrently or data
    // loss could happen.
    final mutex = Mutex();
    await mutex.acquire();

    try {
      var masterKeyBase64 = await storage.read(key: _masterKey);

      if (masterKeyBase64 == null) {
        // No master password was generated yet, generate one now.
        masterKeyBase64 = Key.fromLength(_keyLengthInBytes).base64;
        await storage.write(key: _masterKey, value: masterKeyBase64);
      }

      return MasterKey._(Key.fromBase64(masterKeyBase64));
    } finally {
      mutex.release();
    }
  }

  String encrypt(String plainText) {
    final iv = IV.fromLength(_ivLengthInBytes);
    // Note that Salsa20 is not AEAD and thus the `associatedData` parameter to
    // `encrypt` is not used.
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    // Pack the IV with the ciphertext for convenience.
    return '${iv.base64}:${encrypted.base64}';
  }

  String encryptBytes(Uint8List plainText) {
    final iv = IV.fromLength(_ivLengthInBytes);
    // Note that Salsa20 is not AEAD and thus the `associatedData` parameter to
    // `encrypt` is not used.
    final encrypted = _encrypter.encryptBytes(plainText, iv: iv);
    // Pack the IV with the ciphertext for convenience.
    return '${iv.base64}:${encrypted.base64}';
  }

  // Returns `null` if decryption fails.
  String? decrypt(String encrypted) {
    final ivAndCipherText = encrypted.split(':');

    if (ivAndCipherText.length != 2) {
      return null;
    }

    final iv = IV.fromBase64(ivAndCipherText[0]);
    final cipherText = ivAndCipherText[1];

    return _encrypter.decrypt64(cipherText, iv: iv);
  }

  // Returns `null` if decryption fails.
  Uint8List? decryptBytes(String encrypted) {
    final ivAndCipherText = encrypted.split(':');

    if (ivAndCipherText.length != 2) {
      return null;
    }

    final iv = IV.fromBase64(ivAndCipherText[0]);
    final cipherText = ivAndCipherText[1];

    return Uint8List.fromList(
        _encrypter.decryptBytes(Encrypted.fromBase64(cipherText), iv: iv));
  }

  @visibleForTesting
  static MasterKey initWithKey(String keyBase64) =>
      MasterKey._(Key.fromBase64(keyBase64));

  @visibleForTesting
  static String generateKey() => Key.fromLength(_keyLengthInBytes).base64;
}

// I think we need the `encryptedSharedPreferense: true` option on Android,
// otherwise we the stored values don't seem to be preserved after app restart.
AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);
