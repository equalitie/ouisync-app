import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import 'utils.dart';

class Permissions {
  static Future<PermissionStatus> requestPermission(
    BuildContext context,
    Permission permission,
  ) async {
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isWindows) {
      // This platform doesn't support permissions. Assume granted.
      return PermissionStatus.granted;
    }

    final status = await permission.request();
    final String message;

    switch (status) {
      case PermissionStatus.granted:
        message = S.current.messageGranted;
        break;

      case PermissionStatus.permanentlyDenied:
        final header = _labels[permission]?.rationale ??
            S.current.messagePermissionRequired;

        message = '$header\n\n${S.current.messageGrantingRequiresSettings}';
        break;

      default:
        message = _labels[permission]?.rationale ??
            S.current.messagePermissionRequired;
        break;
    }

    if (status != PermissionStatus.granted) {
      final actions = status == PermissionStatus.permanentlyDenied
          ? <Widget>[
              TextButton(
                child: Text(S.current.actionCloseCapital),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(false),
              ),
              TextButton(
                  child: Text(S.current.actionGoToSettings.toUpperCase()),
                  onPressed: () {
                    openAppSettings();

                    Navigator.of(context, rootNavigator: true).pop(true);
                  })
            ]
          : <Widget>[
              TextButton(
                child: Text(S.current.actionCloseCapital),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(false),
              )
            ];

      final name = (_labels[permission]?.name)!;

      await Dialogs.alertDialogWithActions(
        context: context,
        title: S.current.titleRequiredPermission,
        body: [Text(name), Dimensions.spacingVerticalDouble, Text(message)],
        actions: actions,
      );
    }

    return status;
  }
}

final _labels = {
  Permission.accessMediaLocation: (
    name: S.current.messageMediaLocation,
    rationale: S.current.messageMediaLocationPermission
  ),
  Permission.camera: (
    name: S.current.messageCamera,
    rationale: S.current.messageCameraPermission,
  ),
  //Permission.ignoreBatteryOptimizations: (
  //  name: TODO,
  //  rationale: S.current.messageIgnoreBatteryOptimizationsPermission,
  //),
  Permission.storage: (
    name: S.current.messageStorage,
    rationale: S.current.messageStoragePermission,
  ),
};
