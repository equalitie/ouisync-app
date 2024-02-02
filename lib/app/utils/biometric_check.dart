import 'package:local_auth/local_auth.dart';

import '../../generated/l10n.dart';
import '../utils/platform/platform.dart';

abstract class SecurityValidations {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricSupported() async {
    if (PlatformValues.isDesktopDevice) return false;

    return _localAuth.isDeviceSupported();
  }

  static Future<bool> validateBiometrics({String? localizedReason}) async {
    localizedReason ??= S.current.messageAccessingSecureStorage;

    return _localAuth.authenticate(localizedReason: localizedReason);
  }

  static Future<bool> canCheckBiometrics() async {
    /// [2023-10-10] We won't support biometric validation for desktop anymore.
    /// Since the secrets protected by biometrics can be easily accessed
    /// regardless of the validation, it does not really offer the security
    /// that is expected.
    if (PlatformValues.isDesktopDevice) return false;

    final isBiometricsAvailable = await _localAuth.canCheckBiometrics;

    // The device doesn't have biometrics
    if (!isBiometricsAvailable) return false;

    final availableBiometrics = await _localAuth.getAvailableBiometrics();

    // The device has biometrics capabilites, but not in use'.
    if (availableBiometrics.isEmpty) return false;

    return true;
  }
}
