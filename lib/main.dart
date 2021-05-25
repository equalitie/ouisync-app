import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/bloc/blocs.dart';
import 'app/data/data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = await Session.open(
        join((await getApplicationSupportDirectory()).path, 'db'));

  final DirectoryRepository foldersRepository = DirectoryRepository();

  Bloc.observer = SimpleBlocObserver();

  runApp(BlocProvider(
    create: (context) => 
      DirectoryBloc(repository: foldersRepository),
    child: OuiSyncApp(
      session: session,
      foldersRepository: foldersRepository,
    ),
  ));
}
