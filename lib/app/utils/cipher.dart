import 'dart:typed_data';

import 'package:cryptography_plus/cryptography_plus.dart'
    show Chacha20, SecretBox, SecretBoxAuthenticationError, SecretKeyData;

final _algorithm = Chacha20.poly1305Aead();

typedef SecretKey = SecretKeyData;

SecretKey randomSecretKey() =>
    SecretKeyData.random(length: _algorithm.secretKeyLength);

Future<Uint8List> encrypt(SecretKey secretKey, Uint8List plainData) async {
  final secretBox = await _algorithm.encrypt(plainData, secretKey: secretKey);
  return secretBox.concatenation();
}

Future<Uint8List?> decrypt(SecretKey secretKey, Uint8List encryptedData) async {
  final nonceLength = _algorithm.nonceLength;
  final macLength = _algorithm.macAlgorithm.macLength;

  final box = SecretBox.fromConcatenation(
    encryptedData,
    nonceLength: nonceLength,
    macLength: macLength,
  );

  try {
    return Uint8List.fromList(
      await _algorithm.decrypt(box, secretKey: secretKey),
    );
  } on SecretBoxAuthenticationError {
    return null;
  }
}
