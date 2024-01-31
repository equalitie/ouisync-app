import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_app/app/background.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'env/env.dart';

/// How often the background syncing runs
const _syncInBackgroundPeriod = Duration(minutes: 15);

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

  final dsn = Env.ouisyncDSN;
  if (dsn == '""') {
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
