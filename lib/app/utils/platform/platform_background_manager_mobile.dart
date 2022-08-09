import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import '../loggers/ouisync_app_logger.dart';
import 'platform.dart';

class PlatformBackgroundManagerMobile 
  with OuiSyncAppLogger
  implements PlatformBackgroundManager {
  
  @override
  Future<void> enableBackgroundExecution(BuildContext context) async {
    final config = FlutterBackgroundAndroidConfig(
      notificationTitle: 'OuiSync',
      notificationText:
          'Background notification for keeping the example app running in the background',
      notificationIcon: AndroidResource(name: 'background_icon'),
      notificationImportance: AndroidNotificationImportance.Default,
      enableWifiLock: true,
    );

    var hasPermissions = await FlutterBackground.hasPermissions;

    if (!hasPermissions) {

      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('Permissions needed'),
                content: Text(
                    "Shortly the OS will ask you for permission to execute "
                    "this app in the background. This is required in order to "
                    "keep syncing while the app is not in the foreground."
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
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