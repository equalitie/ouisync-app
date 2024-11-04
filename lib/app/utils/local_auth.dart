import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../generated/l10n.dart';

abstract class LocalAuth {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    if (_useDebug()) {
      return true;
    }

    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      // We get here on Linux as there this plugin isn't supported.
      return false;
    }
  }

  // This is a "best effort" to authenticate the user, but if the device
  // doesn't support authentication, then we proceed as if authenticated.
  static Future<bool> authenticateIfPossible(
      BuildContext context, String? reason) async {
    reason ??= S.current.messageAccessingSecureStorage;

    if (_useDebug()) {
      final authenticated = await _debugAuthenticate(context, reason);
      return authenticated;
    }

    if (!await canAuthenticate()) {
      return true;
    }

    try {
      return _localAuth.authenticate(localizedReason: reason);
    } catch (e) {
      return true;
    }
  }

  static bool _useDebug() {
    if (kReleaseMode) return false;
    if (Platform.isLinux) return true;
    return false;
  }
}

// local_auth is not available on some platforms, so to avoid debugging on
// platforms where it is available, here is a small "dummy" authentication
// dialog.
Future<bool> _debugAuthenticate(BuildContext context, String reason) async {
  Widget button(context, text, value) => TextButton(
        child: Text(text),
        onPressed: () => Navigator.of(context).pop(value),
      );

  bool? authenticated = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text("Is it you?"),
            content: Text(reason),
            actions: [
              button(context, "Yes", true),
              button(context, "No", false),
              button(context, "Cancel", null),
            ],
          ));

  authenticated = authenticated ?? false;

  return authenticated;
}
