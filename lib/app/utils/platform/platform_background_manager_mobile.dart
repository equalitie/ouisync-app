import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import '../../../generated/l10n.dart';
import '../loggers/ouisync_app_logger.dart';
import 'platform.dart';

class PlatformBackgroundManagerMobile
    with OuiSyncAppLogger
    implements PlatformBackgroundManager {
  @override
  Future<void> enableBackgroundExecution(BuildContext context) async {
    final config = FlutterBackgroundAndroidConfig(
      notificationTitle: S.current.titleAppTitle,
      notificationText: S.current.messageBackgroundNotificationAndroid,
      notificationIcon: const AndroidResource(name: 'notification_icon'),
      notificationImportance: AndroidNotificationImportance.Default,
      enableWifiLock: true,
    );

    var hasPermissions = await FlutterBackground.hasPermissions;

    if (!hasPermissions) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text(S.current.titleBackgroundAndroidPermissionsTitle),
                content: Text(S.current.messageBackgroundAndroidPermissions),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: Text(S.current.actionOK),
                  ),
                ]);
          });
    }

    hasPermissions = await FlutterBackground.initialize(androidConfig: config);

    if (hasPermissions) {
      final backgroundExecution =
          await FlutterBackground.enableBackgroundExecution();

      if (backgroundExecution) {
        loggy.app("Background execution enabled");
      } else {
        loggy.app("Background execution NOT enabled");
      }
    } else {
      loggy.app("No permissions to enable background execution");
    }
  }
}
