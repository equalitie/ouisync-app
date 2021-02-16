import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/bloc/simpleblocobserver.dart';
import 'package:ouisync_app/app/data/repositories/directoryrepository.dart';

import 'app/bloc/blocs.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();

  final DirectoryRepository directoryRepository = DirectoryRepository();

  runApp(
    MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  DirectoryBloc(repository: directoryRepository)
          )
        ], child: OuiSyncApp(directoryRepository: directoryRepository,))
  );
}
