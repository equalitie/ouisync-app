import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'env/env.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
    
  const appSuffix = String.fromEnvironment('DEV_SUFFIX');
  final dsn = Env.ouisyncDSN;

  await setupSentry(
      () async => runApp(await initOuiSyncApp(args, appSuffix)), dsn);
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
