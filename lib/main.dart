import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/bloc/blocs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = await Session.open(
        join((await getApplicationSupportDirectory()).path, 'db'));

  final repository = await Repository.open(session);

  Bloc.observer = SimpleBlocObserver();

  runApp(OuiSyncApp(
      session: session,
      repository: repository
    ));
}
