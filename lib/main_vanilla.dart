import 'package:flutter/material.dart';

import 'app/app.dart';
import 'flavors.dart';

Future<void> main() async {
  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  print(
      "------------------------ OuiSync (vanilla) Start ------------------------");

  F.appFlavor = Flavor.vanilla;

  WidgetsFlutterBinding.ensureInitialized();

  final app = await initOuiSyncApp();
  runApp(app);
}
