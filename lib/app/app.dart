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
    required this.repository,
    required this.directoryRepository,
  });

  final Session session;
  final Repository repository;
  final DirectoryRepository directoryRepository;

  @override
  _OuiSyncAppState createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> {

  late final NavigationBloc navigationBloc;

  @override
  void initState() {
    super.initState();

    NativeChannels.init(widget.session);

    navigationBloc = NavigationBloc(
      directoryRepository: widget.directoryRepository
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
            blocRepository: widget.directoryRepository
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