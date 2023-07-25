import 'package:flutter/material.dart';

import 'app/app.dart';
import 'flavors.dart';

Future<void> main(List<String> args) async {
  F.appFlavor = Flavor.vanilla;

  WidgetsFlutterBinding.ensureInitialized();

  final app = await initOuiSyncApp(args);
  runApp(app);
}
