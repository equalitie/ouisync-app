import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart' show App;

// Set this when making a release by passing `--dart-define=SENTRY_DSN=***...***`
// to the `flutter build` or the `flutter run` commands.
const _sentryDSN = String.fromEnvironment('SENTRY_DSN');

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // start app, possibly proxied via sentry if configured
  void start() => runApp(App(args));

  if (_sentryDSN != '') {
    await setupSentry(start, _sentryDSN);
  } else {
    start();
  }
}

Future<void> setupSentry(
  AppRunner appRunner,
  String dsn, {
  bool isIntegrationTest = false,
  BeforeSendCallback? beforeSendCallback,
}) => SentryFlutter.init((options) {
  options
    ..dsn = dsn
    ..tracesSampleRate = 1.0;

  if (isIntegrationTest) {
    options
      ..dist = '1'
      ..environment = 'integration'
      ..beforeSend = beforeSendCallback;
  }
}, appRunner: appRunner);
