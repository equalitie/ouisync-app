import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart';
import 'pages/pages.dart';
import 'utils/loggers/ouisync_app_logger.dart';
import 'utils/platform/platform.dart';
import 'utils/utils.dart';

Future<Widget> initOuiSyncApp() async {
  final windowManager = PlatformWindowManager();

  Loggy.initLoggy();

  final appDir = (await getApplicationSupportDirectory()).path;
  final configDir = p.join(appDir, Constants.configuratiosDirName);

  if (kDebugMode) {
    print(appDir);
    print(configDir);
  }

  // TODO: Maybe we don't need to await for this, instead just get the future
  // and let whoever needs seetings to await for it.
  final settings = await Settings.init();

  final session = await Session.open(configDir);

  return MaterialApp(
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
        windowManager: windowManager,
        settings: settings,
      ));
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

class _OuiSyncAppState extends State<OuiSyncApp> with OuiSyncAppLogger {
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
    return Scaffold(
      body: MultiBlocProvider(
          providers: [
            BlocProvider<UpgradeExistsCubit>(
                create: (BuildContext context) => UpgradeExistsCubit(
                    widget.session.currentProtocolVersion, widget.settings)),
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
                  mediaReceiver: _mediaReceiver,
                  settings: widget.settings))),
    );
  }
}
