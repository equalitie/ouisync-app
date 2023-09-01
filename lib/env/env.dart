import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'DSN', obfuscate: true)
  static final String ouisyncDSN = _Env.ouisyncDSN;
}
