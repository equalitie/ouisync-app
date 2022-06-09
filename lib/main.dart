import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/utils/utils.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  Loggy.initLoggy();

  final appDir = (await getApplicationSupportDirectory()).path;
  final repositoriesDir = p.join(appDir, Constants.folderRepositoriesName);
  final configDir = p.join(appDir, Constants.configuratiosDirName);

  if (kDebugMode) {
    print(appDir);

    print(configDir);
    print(repositoriesDir);
  }

  await Settings.initSettings(
    appDir,
    repositoriesDir,
  );

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: 'OuiSync - Secure file-sharing and real-time sync, with or without internet',
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final localRepositoriesList = RepositoryHelper
  .localRepositoriesFiles(repositoriesDir) as List<String>;
  
  final latestRepositoryOrDefaultName = await RepositoryHelper
  .latestRepositoryOrDefault(localRepositoriesList);
  
  await Settings.saveSetting(
      Constants.currentRepositoryKey, latestRepositoryOrDefaultName);

  final session = await Session.open(configDir);
  
  BlocOverrides.runZoned(
    () => runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
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
        ))),
  );
}
