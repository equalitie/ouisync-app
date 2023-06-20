import 'package:flutter/material.dart';

import 'app/app.dart';
import 'flavors.dart';

Future<void> main() async {
  F.appFlavor = Flavor.vanilla;

  WidgetsFlutterBinding.ensureInitialized();

  final app = await initOuiSyncApp();
  runApp(app);
}
