import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'bloc/blocs.dart';
import 'cubit/cubits.dart';
import 'data/data.dart';
import 'pages/pages.dart';

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

class _OuiSyncAppState extends State<OuiSyncApp> {
  final StreamController<List<SharedMediaFile>> _sharedMediaStreamController = StreamController<List<SharedMediaFile>>();
  StreamSubscription? _intentDataStreamSubscription;
  
  @override
  void initState() {
    super.initState();
    NativeChannels.init();

    _processSharedIntent();
  }

  void _processSharedIntent() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent
    .getMediaStream().listen((List<SharedMediaFile> listOfMedia) {
      if (listOfMedia.isEmpty) {
        print('[intent_listener] No media present');
        return;
      }

      print('[intent_listener] Media shared: ${(listOfMedia.map((f)=> f.path).join(","))}');
      _sharedMediaStreamController.add(listOfMedia);
    }, onError: (err) {
      print("[intent_listener] Error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> listOfMedia) {
      if (listOfMedia.isEmpty) {
        print('[intent] No media present');
        return;
      }

      print('[intent] Media shared: ${(listOfMedia.map((f)=> f.path).join(","))}');
      _sharedMediaStreamController.add(listOfMedia);
    });
  }

  @override
  void dispose() {
    _sharedMediaStreamController.close();
    _intentDataStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DirectoryBloc>(
            create: (BuildContext context) => DirectoryBloc(directoryRepository: DirectoryRepository()),
          ),
          BlocProvider<RouteBloc>(
            create: (BuildContext context) => RouteBloc()
          ),
          BlocProvider<SynchronizationCubit>(
            create: (BuildContext context) => SynchronizationCubit()
          ),
          BlocProvider<RepositoriesCubit>(
            create: (BuildContext context) => RepositoriesCubit(  
              session: widget.session,
              appDir: widget.appStorageLocation,
              repositoriesDir: widget.repositoriesLocation
            )
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
