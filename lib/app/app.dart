import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart';
import 'pages/pages.dart';
import 'utils/settings.dart';
import 'utils/loggers/ouisync_app_logger.dart';
import 'utils/platform/platform.dart';

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.session,
    required this.repositoriesLocation,
    required this.windowManager,
    required this.settings,
    Key? key,
  }) : super(key: key);

  final Session session;
  final String repositoriesLocation;
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
                  repositoriesLocation: widget.repositoriesLocation,
                  mediaReceiver: _mediaReceiver,
                  settings: widget.settings))),
    );
  }
}
