import 'package:flutter/material.dart';
import 'package:ouisync_app/flavors.dart';

import 'app/app.dart';

Future<void> main() async {
  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  print("------------------------ OuiSync Start ------------------------");

  F.appFlavor = Flavor.VANILLA;

  WidgetsFlutterBinding.ensureInitialized();

  final app = await initOuiSyncApp();
  runApp(app);
}
