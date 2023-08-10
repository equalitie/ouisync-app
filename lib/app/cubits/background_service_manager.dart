import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class BackgroundServiceManagerState {
  bool isServiceRunning;
  bool finishedInitialization;

  BackgroundServiceManagerState(
      {required this.isServiceRunning, required this.finishedInitialization});
}

class BackgroundServiceManager extends Cubit<BackgroundServiceManagerState>
    with AppLogger {
  BackgroundServiceManager()
      : super(BackgroundServiceManagerState(
            isServiceRunning: Platform.isAndroid ? false : true,
            finishedInitialization: false));

  bool showWarning() {
    return !state.isServiceRunning && state.finishedInitialization;
  }

  bool isServiceRunning() {
    return state.isServiceRunning;
  }

  Future<void> maybeRequestPermissionsAndStartService(
      BuildContext context) async {
    if (isServiceRunning()) {
      return;
    }

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
                title: Fields.constrainedText(
                    S.current.titleBackgroundAndroidPermissionsTitle,
                    flex: 0,
                    style: context.theme.appTextStyle.titleLarge,
                    maxLines: 2),
                content: Text(S.current.messageBackgroundAndroidPermissions,
                    style: context.theme.appTextStyle.bodyMedium),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop('OK'),
                      child: Text(S.current.actionOK))
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

    var isRunning = false;

    if (initializationOk) {
      final backgroundExecution =
          await FlutterBackground.enableBackgroundExecution();

      if (backgroundExecution) {
        loggy.app("Background execution enabled");
        isRunning = true;
      } else {
        loggy.app("Background execution NOT enabled");
      }
    } else {
      loggy.app("No permissions to enable background execution");
    }

    emit(BackgroundServiceManagerState(
        isServiceRunning: isRunning, finishedInitialization: true));
  }
}
