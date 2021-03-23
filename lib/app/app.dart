import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/data/data.dart';

import '../lifecycle.dart';
import 'pages/pages.dart';
import 'utils/utils.dart';

class OuiSyncApp extends StatelessWidget {
  const OuiSyncApp({
    Key key,
    @required this.reposBaseFolderPath,
    @required this.foldersRepository
  }) : 
  assert(reposBaseFolderPath != null),
  assert(reposBaseFolderPath != ""),
  assert(foldersRepository != null),
  super(key: key);

  final String reposBaseFolderPath;
  final DirectoryRepository foldersRepository;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: titleApp,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LifeCycle(
        child: RootPage(
          reposBaseFolderPath: reposBaseFolderPath,
          foldersRepository: foldersRepository,
          title: titleRootPage,
        )
      ),
    );
  }
}