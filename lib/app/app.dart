import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final StreamController<List<SharedMediaFile>> _sharedMediaStreamController = StreamController<List<SharedMediaFile>>();
  StreamSubscription? _intentDataStreamSubscription;

  Subscription? _networkSubscription;
  
  @override
  void initState() {
    super.initState();
    NativeChannels.init();

    _processSharedIntent();
    _subscribeToNetworkNotifications();
  }

  void _processSharedIntent() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent
    .getMediaStream().listen((List<SharedMediaFile> listOfMedia) {
      if (listOfMedia.isEmpty) {
        loggy.app('No media present (intent_listener)');
        return;
      }

      loggy.app('Media shared: ${(listOfMedia.map((f)=> f.path).join(","))} (intent_listener)');
      _sharedMediaStreamController.add(listOfMedia);
    }, onError: (err) {
      loggy.app("Error: $err (intent_listener)");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> listOfMedia) {
      if (listOfMedia.isEmpty) {
        loggy.app('No media present (intent)');
        return;
      }

      loggy.app('Media shared: ${(listOfMedia.map((f)=> f.path).join(","))} (intent)');
      _sharedMediaStreamController.add(listOfMedia);
    });
  }

  void _subscribeToNetworkNotifications() {
    _networkSubscription = widget.session.subscribeToNetworkEvents(_notifyNetworkEvent);
  }

  void _notifyNetworkEvent(NetworkEvent event) {
    String message = '';
    switch (event) {
      case NetworkEvent.protocolVersionMismatch:
        message = S.current.messageProtocolVersionMismatch;
        break;
    }
    
    if (message.isNotEmpty) {
      Fluttertoast.showToast(msg: message); 
    }
  }

  @override
  void dispose() {
    _sharedMediaStreamController.close();
    _intentDataStreamSubscription?.cancel();

    _networkSubscription?.cancel();

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
            create: (BuildContext context) => DirectoryBloc(directoryRepository: DirectoryRepository()),
          ),
          BlocProvider<RepositoriesCubit>(
            create: (BuildContext context) => RepositoriesCubit(  
              session: widget.session,
              appDir: widget.appStorageLocation,
              repositoriesDir: widget.repositoriesLocation
            )
          ),
          BlocProvider<ConnectivityCubit>(
            create: (BuildContext context) => ConnectivityCubit()
          )
        ],
        child: MainPage(
          session: widget.session,
          repositoriesLocation: widget.repositoriesLocation,
          defaultRepositoryName: widget.defaultRepositoryName,
          intentStream: _sharedMediaStreamController.stream,
        )
      )
    );
  }
}
