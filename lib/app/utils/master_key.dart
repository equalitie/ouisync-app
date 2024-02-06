import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:mutex/mutex.dart';

class MasterKey {
  static const String _masterKey = 'masterKey';
  static const int _keyLengthInBytes = 32; // For Salsa20
  static const int _ivLengthInBytes = 8; // For Salsa20

  final Encrypter _encrypter;

  MasterKey._(Key masterKey) : _encrypter = Encrypter(Salsa20(masterKey));

  static Future<MasterKey> init() async {
    // Don't use the `encryptedSharedPreferences: true` option as that is
    // available only on Android version >= 7.0.  Before that, and since
    // Android 4.3 (API level 18), the KeyStore was used, and that is enough
    // for our use case.
    final storage = FlutterSecureStorage(aOptions: AndroidOptions());

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
}
