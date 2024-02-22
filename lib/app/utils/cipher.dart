import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';

class Cipher {
  final FlutterChacha20 _algorithm;
  final SecretKey secretKey;

  Cipher(this.secretKey) : _algorithm = FlutterChacha20.poly1305Aead();

  static Future<Cipher> newWithRandomKey() async {
    final algorithm = FlutterChacha20.poly1305Aead();
    final key = await algorithm.newSecretKey();
    return Cipher._(key, algorithm);
  }

  Cipher._(this.secretKey, this._algorithm);

  Future<String> encrypt(String data) async {
    final dataBytes = utf8.encode(data);
    final secretBox = await _algorithm.encrypt(dataBytes, secretKey: secretKey);

    final encryptedBytes = secretBox.concatenation();
    final encryptedData = base64Encode(encryptedBytes);

    return encryptedData;
  }

  Future<String> decrypt(String encryptedData) async {
    final nonceLength = _algorithm.nonceLength;
    final macLength = _algorithm.macAlgorithm.macLength;
    final encryptedDataBytes = base64Decode(encryptedData);

    final secretBox = SecretBox.fromConcatenation(encryptedDataBytes,
        nonceLength: nonceLength, macLength: macLength);

    final decryptedData =
        await _algorithm.decryptString(secretBox, secretKey: secretKey);

    return decryptedData;
  }
}
