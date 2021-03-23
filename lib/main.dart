import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/bloc/blocs.dart';
import 'app/data/data.dart';
import 'app/utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final OuisyncRepository reposRepository = OuisyncRepository();
  final DirectoryRepository foldersRepository = DirectoryRepository();
  
  final String reposBaseFolderPath = await _getReposBaseFolderPath();

  Bloc.observer = SimpleBlocObserver();

  runApp(BlocProvider(
    create: (context) => 
      RepositoryBloc(repository: reposRepository),
    child: OuiSyncApp(
      reposBaseFolderPath: reposBaseFolderPath,
      foldersRepository: foldersRepository,
    )
  ));
}

Future<String> _getReposBaseFolderPath() async {
  final Directory supportDirectory = await getApplicationSupportDirectory();
  return '${supportDirectory.path}/$repositoriesFolder';
}
