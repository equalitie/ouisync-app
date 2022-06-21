import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../generated/l10n.dart';
import 'bloc/blocs.dart';
import 'cubit/cubits.dart';
import 'pages/pages.dart';
import 'utils/loggers/ouisync_app_logger.dart';
import 'utils/platform/platform.dart';

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.session,
    required this.appStorageLocation,
    required this.repositoriesLocation,
    required this.defaultRepositoryName,
    required this.windowManager,
    Key? key,
  }) : super(key: key);

  final Session session;
  final String appStorageLocation;
  final String repositoriesLocation;
  final String defaultRepositoryName;
  final PlatformWindowManager windowManager;

  @override
  _OuiSyncAppState createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> with OuiSyncAppLogger {
  final _mediaReceiver = MediaReceiver();

  @override
  void initState() {
    super.initState();

    NativeChannels.init();

    initWindowManager();
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: S.of(context).titleAppTitle,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MultiBlocProvider(
            providers: [
              BlocProvider<DirectoryBloc>(
                create: (BuildContext context) => DirectoryBloc(),
              ),
              BlocProvider<UpgradeExistsCubit>(
                  create: (BuildContext context) => UpgradeExistsCubit(
                      widget.session.current_protocol_version)),
              BlocProvider<RepositoriesCubit>(
                  create: (BuildContext context) => RepositoriesCubit(
                      session: widget.session,
                      appDir: widget.appStorageLocation,
                      repositoriesDir: widget.repositoriesLocation)),
              BlocProvider<RepositoryProgressCubit>(
                  create: (BuildContext context) => RepositoryProgressCubit()),
              BlocProvider<ConnectivityCubit>(
                  create: (BuildContext context) => ConnectivityCubit()),
              BlocProvider<PeerSetCubit>(
                  create: (BuildContext context) => PeerSetCubit())
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
                    defaultRepositoryName: widget.defaultRepositoryName,
                    mediaReceiver: _mediaReceiver,))));
  }
}
