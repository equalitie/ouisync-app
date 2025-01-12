import 'package:ouisync/ouisync.dart';

// This class exists mainly to avoid passing the ouisync Session throughout the
// code where only it's password hashing functionality is needed.
class PasswordHasher {
  final Session _ouisyncSession;

  PasswordHasher(this._ouisyncSession);

  Future<LocalSecretKeyAndSalt> hashPassword(
    LocalPassword password, [
    PasswordSalt? salt,
  ]) async {
    salt = salt ?? PasswordSalt.random();
    final key = await _ouisyncSession.deriveSecretKey(password, salt);

    return LocalSecretKeyAndSalt(key, salt);
  }
}
