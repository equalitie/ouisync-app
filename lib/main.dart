import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/bloc/simpleblocobserver.dart';
import 'app/utils/utils.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = (await getApplicationSupportDirectory()).path;
  final repositoriesDir = '$appDir/${Strings.folderRepositoriesName}';
  final configDir = '$appDir/${Strings.configuratiosDirName}';

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
