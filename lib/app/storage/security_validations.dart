import 'dart:io' as io;

import 'package:local_auth/local_auth.dart';

import '../../generated/l10n.dart';

abstract class SecurityValidations {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricSupported() => _localAuth.isDeviceSupported();

  static Future<bool> validateBiometrics({String? localizedReason}) async {
    localizedReason ??= S.current.messageAccessingSecureStorage;

    return _localAuth.authenticate(localizedReason: localizedReason);
  }

  static Future<bool?> canCheckBiometrics() async {
    if (!io.Platform.isAndroid &&
        !io.Platform.isIOS &&
        !io.Platform.isWindows) {
      return null;
    }

    final isBiometricsAvailable = await _localAuth.canCheckBiometrics;

    // The device doesn't have biometrics
    if (!isBiometricsAvailable) return null;

    final availableBiometrics = await _localAuth.getAvailableBiometrics();

    // The device has biometrics capabilites, but not in use'.
    if (availableBiometrics.isEmpty) return false;

    return true;
  }
}
