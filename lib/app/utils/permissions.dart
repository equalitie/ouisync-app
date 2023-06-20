import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import 'utils.dart';

class Permissions with AppLogger {
  static Future<PermissionResult> requestPermission(
      BuildContext context, Permission permission, String name) async {
    PermissionStatus status =
        await Permission.byValue(permission.value).request();

    final String message;

    switch (status) {
      case PermissionStatus.granted:
        message = S.current.messageGranted;
        break;

      case PermissionStatus.permanentlyDenied:
        message =
            '${ouiSyncPermissions[permission] ?? S.current.messagePermissionRequired}'
            '\n\n${S.current.messageGrantingRequiresSettings}';
        break;

      default:
        message = ouiSyncPermissions[permission] ??
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

      await Dialogs.alertDialogWithActions(
          context: context,
          title: S.current.titleRequiredPermission,
          body: [
            Text(name,
                style: TextStyle(
                    fontSize: Dimensions.fontBig, fontWeight: FontWeight.w400)),
            Dimensions.spacingVerticalDouble,
            Text(message)
          ],
          actions: actions);
    }

    return PermissionResult(
        permission: permission, status: status, resultMessage: message);
  }
}

class PermissionResult {
  PermissionResult(
      {required this.permission, required this.status, this.resultMessage});

  final Permission permission;
  final PermissionStatus status;
  final String? resultMessage;
}

final ouiSyncPermissions = {
  Permission.camera: S.current.messageCameraPermission,
  Permission.ignoreBatteryOptimizations:
      S.current.messageIgnoreBatteryOptimizationsPermission,
  Permission.storage: S.current.messageStoragePermission
};
