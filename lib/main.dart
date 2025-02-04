import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/background.dart';
import 'app/utils/dirs.dart';

/// How often the background syncing runs
// TODO: using short period of 5 minutes for now to simplify debugging but once things stabilize
// a bit we should increase it (say to 15 minutes) to reduce battery drain.
// TODO: prove that this is not extremely memory inefficient or reimplement it on the native side
const _syncInBackgroundPeriod = Duration(minutes: 5);

// Set this when making a release by passing `--dart-define=SENTRY_DSN=***...***`
// to the `flutter build` or the `flutter run` commands.
const _sentryDSN = String.fromEnvironment('SENTRY_DSN');

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  var dirs = await Dirs.init();
  await LogUtils.init(dirs);

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

  // start app, possibly proxied via sentry if configured
  Future<void> start() async => runApp(
        await initOuiSyncApp(dirs: dirs, args: args),
      );
  await (_sentryDSN != "" ? setupSentry(start, _sentryDSN) : start());
}

Future<void> setupSentry(
  AppRunner ouisyncAppRunner,
  String dsn, {
  bool isIntegrationTest = false,
  BeforeSendCallback? beforeSendCallback,
}) async {
  await SentryFlutter.init((options) {
    options
      ..dsn = dsn
      ..tracesSampleRate = 1.0;

    if (isIntegrationTest) {
      options
        ..dist = '1'
        ..environment = 'integration'
        ..beforeSend = beforeSendCallback;
    }
  }, appRunner: ouisyncAppRunner);
}
