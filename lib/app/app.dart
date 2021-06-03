import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../lifecycle.dart';
import 'data/data.dart';
import 'pages/pages.dart';
import 'utils/utils.dart';

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.session,
    required this.foldersRepository,
  });

  final Session session;
  final DirectoryRepository foldersRepository;

  @override
  _OuiSyncAppState createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: titleApp,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LifeCycle(
        session: widget.session,
        child: RootFolderPage(
          session: widget.session,
          foldersRepository: widget.foldersRepository,
          path: '/',
          title: 'OuiSync - /'
        ),
      ),
    );
  }
}