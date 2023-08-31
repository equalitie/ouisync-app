import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'DSN', obfuscate: true)
  static final String ouisyncDSN = _Env.ouisyncDSN;
  @EnviedField(varName: 'DEBUG', defaultValue: true)
  static const bool isDebug = _Env.isDebug;
}
