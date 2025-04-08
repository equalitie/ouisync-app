import 'dart:math';

import 'package:ouisync/ouisync.dart';

SecretKey randomSecretKey() => SecretKey(_randomBytes(32));

PasswordSalt randomSalt() => PasswordSalt(_randomBytes(16));

List<int> _randomBytes(int size) {
  final rng = Random.secure();
  return List.generate(size, (_) => rng.nextInt(256));
}
