import 'package:flutter/material.dart';

import 'app/app.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await initOuiSyncApp(args);
  runApp(app);
}
