import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
export 'package:cryptography/cryptography.dart' show SecretKey;
import 'package:cryptography_flutter/cryptography_flutter.dart';

class Cipher {
  final FlutterChacha20 _algorithm;
  final SecretKey secretKey;

  static FlutterChacha20 newAlgorithm() => FlutterChacha20.poly1305Aead();

  Cipher(this.secretKey) : _algorithm = newAlgorithm();

  static Future<Cipher> newWithRandomKey() async {
    final algorithm = FlutterChacha20.poly1305Aead();
    final key = await algorithm.newSecretKey();
    return Cipher.newFromKeyAndAlgorithm(key, algorithm);
  }

  static SecretKeyData randomSecretKey(FlutterChacha20 algorithm) {
    return SecretKeyData.random(
      length: algorithm.secretKeyLength,
      random: Random.secure(),
    );
  }

  Cipher.newFromKeyAndAlgorithm(this.secretKey, this._algorithm);

  Future<String> encrypt(String data) async {
    return await encryptBytes(utf8.encode(data));
  }

  Future<String> encryptBytes(Uint8List data) async {
    final secretBox = await _algorithm.encrypt(data, secretKey: secretKey);

    final encryptedBytes = secretBox.concatenation();
    final encryptedData = base64Encode(encryptedBytes);

    return encryptedData;
  }

  Future<String?> decrypt(String encryptedData) async {
    final secretBox = _boxFromString(encryptedData);

    try {
      return await _algorithm.decryptString(secretBox, secretKey: secretKey);
    } on SecretBoxAuthenticationError catch (e) {
      return null;
    }
  }

  Future<Uint8List?> decryptBytes(String encryptedData) async {
    final secretBox = _boxFromString(encryptedData);

    try {
      return Uint8List.fromList(
          await _algorithm.decrypt(secretBox, secretKey: secretKey));
    } on SecretBoxAuthenticationError catch (e) {
      return null;
    }
  }

  SecretBox _boxFromString(String box) {
    final nonceLength = _algorithm.nonceLength;
    final macLength = _algorithm.macAlgorithm.macLength;
    final encryptedDataBytes = base64Decode(box);

    return SecretBox.fromConcatenation(encryptedDataBytes,
        nonceLength: nonceLength, macLength: macLength);
  }
}
