import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final dsn = '';
  await setupSentry(() async => runApp(await initOuiSyncApp(args)), dsn);
}

Future<void> setupSentry(AppRunner ouisyncAppRunner, String ouisyncDSN,
    {bool isIntegrationTest = false,
    BeforeSendCallback? beforeSendCallback}) async {
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
