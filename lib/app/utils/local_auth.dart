import 'package:local_auth/local_auth.dart';

import '../../generated/l10n.dart';
//import '../utils/platform/platform.dart';

abstract class LocalAuth {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    //if (PlatformValues.isDesktopDevice) return false;
    final bool canAuthenticateWithBiometrics =
        await _localAuth.canCheckBiometrics;
    return canAuthenticateWithBiometrics ||
        await _localAuth.isDeviceSupported();
  }

  //static Future<bool> validateBiometrics({String? localizedReason}) async {
  static Future<bool> authenticateIfPossible({String? localizedReason}) async {
    localizedReason ??= S.current.messageAccessingSecureStorage;
    return _localAuth.authenticate(localizedReason: localizedReason);
  }
}
