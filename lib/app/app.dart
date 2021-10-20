import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'bloc/blocs.dart';
import 'cubit/cubits.dart';
import 'data/data.dart';
import 'pages/pages.dart';
import 'utils/utils.dart';

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.appDir,
    required this.repositoriesDir,
    required this.session,
    required this.defaultRepository,
    required this.defaultRepositoryName,
  });

  final String appDir;
  final String repositoriesDir;
  final Session session;
  final Repository? defaultRepository;
  final String defaultRepositoryName;

  @override
  _OuiSyncAppState createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> {
  late final DirectoryRepository directoryRepository;

  @override
  void initState() {
    super.initState();

    NativeChannels.init(repository: widget.defaultRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: titleApp,
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
              appDir: widget.appDir,
              repositoriesDir: widget.repositoriesDir
            )
          )
        ],
        child: MainPage(
          defaultRepository: widget.defaultRepository,
          defaultRepositoryName: widget.defaultRepositoryName,
          title: titleApp,
        )
      )
    );
  }
}