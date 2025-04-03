import 'package:ouisync/ouisync.dart';

import 'random.dart';

// This class exists mainly to avoid passing the ouisync Session throughout the
// code where only it's password hashing functionality is needed.
class PasswordHasher {
  final Session _ouisyncSession;

  PasswordHasher(this._ouisyncSession);

  Future<SetLocalSecretKeyAndSalt> hashPassword(
    Password password, [
    PasswordSalt? salt,
  ]) async {
    salt = salt ?? randomSalt();
    final key = await _ouisyncSession.deriveSecretKey(password, salt);

    return SetLocalSecretKeyAndSalt(key: key, salt: salt);
  }
}
