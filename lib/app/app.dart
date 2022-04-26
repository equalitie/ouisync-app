import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../generated/l10n.dart';
import 'bloc/blocs.dart';
import 'cubit/cubits.dart';
import 'pages/pages.dart';
import 'utils/loggers/ouisync_app_logger.dart';

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.session,
    required this.appStorageLocation,
    required this.repositoriesLocation,
    required this.defaultRepositoryName,
  });

  final Session session;
  final String appStorageLocation;
  final String repositoriesLocation;
  final String defaultRepositoryName;

  @override
  _OuiSyncAppState createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> with OuiSyncAppLogger {
  final StreamController<List<SharedMediaFile>> _mediaIntentStreamController = StreamController<List<SharedMediaFile>>();
  StreamSubscription? _mediaIntentSubscription;

  final StreamController<String> _textIntentStreamController = StreamController<String>();
  StreamSubscription? _textIntentSubscription;
  
  @override
  void initState() {
    super.initState();
    NativeChannels.init();

    _setupReceivingMediaIntents();
    _setupReceivingTextIntents();
  }

  // For receiving media intents.
  void _setupReceivingMediaIntents() {
    // For sharing images coming from outside the app while the app is in the memory
    _mediaIntentSubscription = ReceiveSharingIntent.getMediaStream().listen(
      (List<SharedMediaFile> listOfMedia) {
        if (listOfMedia.isEmpty) {
          loggy.app('No media present (intent_listener)');
          return;
        }

        loggy.app('Media shared: ${(listOfMedia.map((f)=> f.path).join(","))} (intent_listener)');
        _mediaIntentStreamController.add(listOfMedia);
      },
      onError: (err) {
        loggy.app("Error: $err (intent_listener)");
      });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(
      (List<SharedMediaFile> listOfMedia) {
        if (listOfMedia.isEmpty) {
          loggy.app('No media present (intent)');
          return;
        }

        loggy.app('Media shared: ${(listOfMedia.map((f)=> f.path).join(","))} (intent)');
        _mediaIntentStreamController.add(listOfMedia);
      });
  }

  // For receiving share tokens intents.
  void _setupReceivingTextIntents() {
    // For sharing intents coming from outside the app while the app is in the memory.
    _textIntentSubscription = ReceiveSharingIntent.getTextStream().listen(
      (String text) { _textIntentStreamController.add(text); },
      onError: (err) { loggy.app("Error: $err (intent_listener)"); });

    // For sharing intents coming from outside the app while the app is closed.
    ReceiveSharingIntent.getInitialText().then(
      (String? text) {
        if (text == null) {
          return;
        }

        _textIntentStreamController.add(text);
      });
  }

  @override
  void dispose() {
    _mediaIntentStreamController.close();
    _mediaIntentSubscription?.cancel();

    _textIntentStreamController.close();
    _textIntentSubscription?.cancel();

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
            create: (BuildContext context) => UpgradeExistsCubit()
          ),
          BlocProvider<RepositoriesCubit>(
            create: (BuildContext context) => RepositoriesCubit(  
              session: widget.session,
              appDir: widget.appStorageLocation,
              repositoriesDir: widget.repositoriesLocation
            )
          ),
          BlocProvider<RepositoryProgressCubit>(
            create: (BuildContext context) => RepositoryProgressCubit()
          ),
          BlocProvider<ConnectivityCubit>(
            create: (BuildContext context) => ConnectivityCubit()
          ),
          BlocProvider<PeerSetCubit>(
            create: (BuildContext context) => PeerSetCubit()
          )
        ],
        child: MainPage(
          session: widget.session,
          repositoriesLocation: widget.repositoriesLocation,
          defaultRepositoryName: widget.defaultRepositoryName,
          mediaIntentStream: _mediaIntentStreamController.stream,
          textIntentStream: _textIntentStreamController.stream,
        )
      )
    );
  }
}
