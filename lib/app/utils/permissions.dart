import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import 'loggers/ouisync_app_logger.dart';
import 'utils.dart';

class Permissions with OuiSyncAppLogger {
  static Future<PermissionResult> requestPermission(
      BuildContext context, Permission permission, String name) async {
    PermissionStatus status =
        await Permission.byValue(permission.value).request();

    final String message;

    switch (status) {
      case PermissionStatus.granted:
        message = 'Granted';
        break;

      case PermissionStatus.permanentlyDenied:
        message =
            '${ouiSyncPermissions[permission] ?? 'This permission is required'}.'
            '\n\nGranting this permission requires navigating to the app settings:'
            '\n\n Settings > Apps & notifications';
        break;

      default:
        message =
            ouiSyncPermissions[permission] ?? 'This permission is required';
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
                  child: Text('APP SETTINGS'),
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
          title: 'Required permission',
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
  // Permission.accessMediaLocation, //not in manifest (denied)
  Permission.camera:
      'We need this permission to use the camera an read the QR code', //mobile_scanner //granted
  Permission.ignoreBatteryOptimizations:
      'Allows the app to keep syncing in the background', //flutter_background //granted
  // Permission.manageExternalStorage, //not in manifest (restricted)
  // Permission.mediaLibrary, //no needed (granted)
  // Permission.photos, //not in manifest (denied)
  Permission.storage: 'Needed for getting access to the files' //denied
};
