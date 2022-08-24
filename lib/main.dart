import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/utils/platform/platform.dart';
import 'app/utils/utils.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  print("------------------------ OuiSync Start ------------------------");

  WidgetsFlutterBinding.ensureInitialized();

  final windowManager = PlatformWindowManager();

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

  final localRepositoriesList =
      await RepositoryHelper.localRepositoryNames(repositoriesDir).toList();

  final defaultRepositoryName =
      await RepositoryHelper.latestRepositoryOrDefault(localRepositoriesList);

  await Settings.setDefaultRepo(defaultRepositoryName);

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
          defaultRepositoryName: defaultRepositoryName,
          windowManager: windowManager
        ))),
  );
}
