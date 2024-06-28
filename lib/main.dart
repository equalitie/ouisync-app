import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/background.dart';

/// How often the background syncing runs
// TODO: using short period of 5 minutes for now to simplify debugging but once things stabilize
// a bit we should increase it (say to 15 minutes) to reduce battery drain.
const _syncInBackgroundPeriod = Duration(minutes: 5);

// Set this when making a release by passing `--dart-define=SENTRY_DSN=***...***`
// to the `flutter build` or the `flutter run` commands.
const _sentryDSN = String.fromEnvironment('SENTRY_DSN');

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupErrorReporting();

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

  if (_sentryDSN == "") {
    runApp(await initOuiSyncApp(args));
  } else {
    await setupSentry(
        () async => runApp(await initOuiSyncApp(args)), _sentryDSN);
  }
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

void _setupErrorReporting() {
  // Errors from flutter
  FlutterError.onError = (details) {
    // Invoke the default handler
    FlutterError.presentError(details);

    _onError(details);
  };

  // Errors from outside of flutter
  PlatformDispatcher.instance.onError = (exception, stack) {
    _onError(FlutterErrorDetails(exception: exception, stack: stack));

    // Invoke the default handler
    return false;
  };
}

void _onError(FlutterErrorDetails details) {
  logError("Unhandled Exception:", details.exception, details.stack);

  unawaited(
      Sentry.captureException(details.exception, stackTrace: details.stack));
}
