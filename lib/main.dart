import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/background.dart';

/// How often the background syncing runs
// TODO: using short period of 5 minutes for now to simplify debugging but once things stabilize
// a bit we should increase it (say to 15 minutes) to reduce battery drain.
const _syncInBackgroundPeriod = Duration(minutes: 5);

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
      _syncInBackgroundPeriod,
      0,
      syncInBackground,
      allowWhileIdle: true,
      exact: false,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  const dsn = bool.hasEnvironment('SENTRY_DSN')
      ? String.fromEnvironment('SENTRY_DSN')
      : null;
  if (dsn == null) {
    runApp(await initOuiSyncApp(args));
  } else {
    await setupSentry(() async => runApp(await initOuiSyncApp(args)), dsn);
  }
}

Future<void> setupSentry(
  AppRunner ouisyncAppRunner,
  String ouisyncDSN, {
  bool isIntegrationTest = false,
  BeforeSendCallback? beforeSendCallback,
}) async {
  await SentryFlutter.init((options) {
    options
      ..dsn = ouisyncDSN
      ..tracesSampleRate = 1.0;

    if (isIntegrationTest) {
      options
        ..dist = '1'
        ..environment = 'integration'
        ..beforeSend = beforeSendCallback;
    }
  }, appRunner: ouisyncAppRunner);
}
