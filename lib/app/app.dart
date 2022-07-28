import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:flutter_background/flutter_background.dart';

import '../generated/l10n.dart';
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

    initWindowManager().then((_) {enableBackgroundExecution();});
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
              BlocProvider<DirectoryCubit>(
                create: (BuildContext context) => DirectoryCubit(),
              ),
              BlocProvider<UpgradeExistsCubit>(
                  create: (BuildContext context) => UpgradeExistsCubit(
                      widget.session.current_protocol_version)),
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
                    appStorageLocation: widget.appStorageLocation,
                    repositoriesLocation: widget.repositoriesLocation,
                    defaultRepositoryName: widget.defaultRepositoryName,
                    mediaReceiver: _mediaReceiver,))));
  }

  void enableBackgroundExecution() async {
    final config = FlutterBackgroundAndroidConfig(
      notificationTitle: 'OuiSync',
      notificationText:
          'Background notification for keeping the example app running in the background',
      notificationIcon: AndroidResource(name: 'background_icon'),
      notificationImportance: AndroidNotificationImportance.Default,
      enableWifiLock: true,
    );

    var hasPermissions = await FlutterBackground.hasPermissions;

    if (!hasPermissions) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('Permissions needed'),
                content: Text(
                    "Shortly the OS will ask you for permission to execute "
                    "this app in the background. This is required in order to "
                    "keep syncing while the app is not in the foreground."
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ]);
          });
    }

    hasPermissions = await FlutterBackground.initialize(androidConfig: config);

    if (hasPermissions) {
      final backgroundExecution =
          await FlutterBackground.enableBackgroundExecution();

      if (backgroundExecution) {
          print("Background execution enabled");
      } else {
          print("Background execution NOT enabled");
      }
    } else {
      print("No permissions to enable background execution");
    }
  }
}
