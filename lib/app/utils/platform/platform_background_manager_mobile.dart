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
      showBadge: false,
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

    // On recent Android versions (13), the first time the plugin is initialized,
    // it fails -even after the user granted permissions. Then on the second run
    // it works as expected.
    //
    // There is curently an issue referencing this in the plugin's repository,
    // and the workaround for it:
    // https://github.com/JulianAssmann/flutter_background/issues/56#issuecomment-1218307725
    final initializationOk =
        await FlutterBackground.initialize(androidConfig: config)
            .then((initialized) async {
      final permissionsOk = await FlutterBackground.hasPermissions;
      if (!initialized && permissionsOk) {
        return await FlutterBackground.initialize(androidConfig: config);
      }

      return initialized;
    });

    if (initializationOk) {
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
