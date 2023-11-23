import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';

abstract class Encrypt {
  static final FlutterChacha20 _algorithm = FlutterChacha20.poly1305Aead();
  static SecretKey? _secretKey;

  static Future<String> encrypt(String data) async {
    _secretKey ??= await _algorithm.newSecretKey();

    final dataBytes = utf8.encode(data);
    final secretBox =
        await _algorithm.encrypt(dataBytes, secretKey: _secretKey!);

    final encryptedBytes = secretBox.concatenation();
    final encryptedData = base64Encode(encryptedBytes);

    return encryptedData;
  }

  static Future<String> decrypt(String encryptedData) async {
    if (_secretKey == null) return '';

    final nonceLength = _algorithm.nonceLength;
    final macLength = _algorithm.macAlgorithm.macLength;
    final encryptedDataBytes = base64Decode(encryptedData);
    
    final secretBox = SecretBox.fromConcatenation(encryptedDataBytes,
        nonceLength: nonceLength, macLength: macLength);

    final decryptedData =
        await _algorithm.decryptString(secretBox, secretKey: _secretKey!);

    return decryptedData;
  }
}
