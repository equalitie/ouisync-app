import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_app/flavors.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  print(
      "------------------------ OuiSync (with Analytics) Start ------------------------");

  F.appFlavor = Flavor.ANALYTICS;

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  final app = await initOuiSyncApp();
  runApp(app);
}
