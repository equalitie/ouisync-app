import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'bloc/blocs.dart';
import 'data/data.dart';
import 'pages/pages.dart';
import 'utils/utils.dart';

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.session,
    required this.repository
  });

  final Session session;
  final Repository repository;

  @override
  _OuiSyncAppState createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> {
  late final DirectoryRepository directoryRepository;
  late final NavigationBloc navigationBloc;

  @override
  void initState() {
    super.initState();

    NativeChannels.init(widget.session);
    initLateObjects();
  }

  void initLateObjects() {
    directoryRepository = DirectoryRepository(repository: widget.repository);
    
    navigationBloc = NavigationBloc(
      directoryRepository: directoryRepository
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(
          create: (BuildContext context) => navigationBloc,
        ),
        BlocProvider<DirectoryBloc>(
          create: (BuildContext context) => DirectoryBloc(
            blocRepository: directoryRepository
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => RouteBloc(bloc: navigationBloc)
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: titleApp,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: RootOuiSync(
          repository: widget.repository,
          path: slash,
          title: titleApp,
        )
      ),
    );
  }
}