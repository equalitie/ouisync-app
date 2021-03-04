import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/data/repositories/directoryrepository.dart';
import 'package:ouisync_app/app/pages/rootpage.dart';
import 'package:ouisync_app/lifecycle.dart';

class OuiSyncApp extends StatelessWidget {
  const OuiSyncApp({
    Key key,
    @required this.directoryRepository
  }) : assert(directoryRepository != null), super(key: key);

  final DirectoryRepository directoryRepository;
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OuiSync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocProvider(
          create: (context) => DirectoryBloc(repository: directoryRepository),
          child: LifeCycle(child: RootPage(title: 'OuiSync repositories')),
          ),  
      );
  }
}