import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'app/app.dart';
import 'app/bloc/simpleblocobserver.dart';
import 'app/utils/utils.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Loggy.initLoggy();

  final storageType = await Constants.storageType;
  await Settings.saveSetting(Constants.storageTypeKey, storageType);

  print('Storage type: $storageType');

  final configDir = await Constants.configPath;
  final repositoriesDir = await Constants.reposPath;

  print('Configuration file path: $configDir');
  print('Repositories path: $repositoriesDir');

  final localRepositoriesList = RepositoryHelper
  .localRepositoriesFiles(repositoriesDir) as List<String>;
  
  final latestRepositoryOrDefaultName = await RepositoryHelper
  .latestRepositoryOrDefault(localRepositoriesList);
  
  await Settings.saveSetting(Constants.currentRepositoryKey, latestRepositoryOrDefaultName);

  final session = await Session.open(configDir);
  
  BlocOverrides.runZoned(
    () => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: OuiSyncApp(session: session)
    )),
    //blocObserver: SimpleBlocObserver(),
  );
}