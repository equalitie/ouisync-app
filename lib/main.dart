import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'app/app.dart';
import 'app/bloc/simpleblocobserver.dart';
import 'app/utils/utils.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Loggy.initLoggy();

  final appDir = (await getApplicationSupportDirectory()).path;
  final repositoriesDir = p.join(appDir, Constants.folderRepositoriesName);
  final configDir = p.join(appDir, Constants.configuratiosDirName);

  print(appDir);

  print(configDir);
  print(repositoriesDir);

  await Settings.initSettings(
    appDir,
    repositoriesDir,
  );

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
      home: OuiSyncApp(
        session: session,
        appStorageLocation: appDir,
        repositoriesLocation: repositoriesDir,
        defaultRepositoryName: latestRepositoryOrDefaultName,
      )
    )),
    //blocObserver: SimpleBlocObserver(),
  );
}
