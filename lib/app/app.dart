import 'dart:async';
import 'dart:io' as io;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../flavors.dart';
import '../generated/l10n.dart';
import 'cubits/cubits.dart';
import 'pages/pages.dart';
import 'utils/platform/platform.dart';
import 'utils/utils.dart';

Future<Widget> initOuiSyncApp() async {
  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  print("-------------------- OuiSync (${F.name}) Start --------------------");

  final windowManager = PlatformWindowManager();

  final appDir = await getApplicationSupportDirectory();
  final configPath = p.join(appDir.path, Constants.configDirName);
  final logPath = await LogUtils.path;

  final session = Session.create(
    configPath: configPath,
    logPath: logPath,
  );

  Loggy.initLoggy(logPrinter: AppLogPrinter());

  _setupErrorReporting();

  logDebug('app dir: ${appDir.path}');
  logDebug('log dir: ${io.File(logPath).parent.path}');

  await session.initNetwork(
    defaultPortForwardingEnabled: true,
    defaultLocalDiscoveryEnabled: true,
  );

  // TODO: Maybe we don't need to await for this, instead just get the future
  // and let whoever needs seetings to await for it.
  final settings = await Settings.init();
  final ouisyncAppHome = OuiSyncApp(
    session: session,
    windowManager: windowManager,
    settings: settings,
  );

  var eqValuesAccepted = settings.getEqualitieValues();
  if (eqValuesAccepted == null) {
    eqValuesAccepted = false;
    await settings.setEqualitieValues(eqValuesAccepted);
  }

  return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(appBarTheme: AppBarTheme(color: F.color)),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: eqValuesAccepted
          ? ouisyncAppHome
          : AcceptEqualitieValuesPage(
              settings: settings, ouisyncAppHome: ouisyncAppHome));
}

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.session,
    required this.windowManager,
    required this.settings,
    Key? key,
  }) : super(key: key);

  final Session session;
  final Settings settings;
  final PlatformWindowManager windowManager;

  @override
  State<OuiSyncApp> createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> with AppLogger {
  final _mediaReceiver = MediaReceiver();
  final _backgroundManager = PlatformBackgroundManager();

  @override
  void initState() {
    super.initState();

    NativeChannels.init();

    initWindowManager().then((_) async =>
        await _backgroundManager.enableBackgroundExecution(context));
  }

  Future<void> initWindowManager() async {
    await widget.windowManager.setTitle(S.current.messageOuiSyncDesktopTitle);
    await widget.windowManager.initSystemTray();
  }

  @override
  void dispose() {
    _mediaReceiver.dispose();

    widget.windowManager.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upgradeExists = UpgradeExistsCubit(
        widget.session.currentProtocolVersion, widget.settings);

    return Scaffold(
      body: MultiBlocProvider(
          providers: [
            // TODO: We have the Cubits class which we thread to widgets that
            // need it, consider getting rid of this BlocProvider pattern.
            BlocProvider<UpgradeExistsCubit>(
                create: (BuildContext context) => upgradeExists),
          ],
          child: DropTarget(
              onDragDone: (detail) {
                loggy.app('Drop done: ${detail.files.first.path}');

                final xFile = detail.files.firstOrNull;
                if (xFile != null) {
                  final file = io.File(xFile.path);
                  _mediaReceiver.controller.add(file);
                }
              },
              onDragEntered: (detail) {
                loggy.app('Drop entered: ${detail.localPosition}');
              },
              onDragExited: (detail) {
                loggy.app('Drop exited: ${detail.localPosition}');
              },
              child: MainPage(
                  session: widget.session,
                  upgradeExists: upgradeExists,
                  mediaReceiver: _mediaReceiver,
                  settings: widget.settings))),
    );
  }
}

void _setupErrorReporting() {
  // Errors from flutter
  FlutterError.onError = (details) {
    // Invoke the default handler
    FlutterError.presentError(details);

    _onError(details);
  };

  // Errors from outside of flutter
  PlatformDispatcher.instance.onError = (exception, stack) {
    _onError(FlutterErrorDetails(exception: exception, stack: stack));

    // Invoke the default handler
    return false;
  };
}

void _onError(FlutterErrorDetails details) {
  logError("Unhandled Exception:", details.exception, details.stack);

  if (Firebase.apps.isNotEmpty) {
    unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
  }
}
