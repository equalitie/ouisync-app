import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/models.dart' show RepoLocation;
import '../utils/utils.dart' show AppLogger;
import 'cubits.dart' show CubitActions;

class NavigationState {
  final RepoLocation? repoLocation;
  final String path;
  final bool isFolder;

  NavigationState({
    required this.repoLocation,
    required this.path,
    required this.isFolder,
  });
}

class NavigationCubit extends Cubit<NavigationState>
    with AppLogger, CubitActions {
  NavigationCubit()
      : super(NavigationState(
          repoLocation: null,
          path: '',
          isFolder: false,
        ));

  void current(RepoLocation repoLocation, String path, bool isFolder) =>
      emitUnlessClosed(NavigationState(
        repoLocation: repoLocation,
        path: path,
        isFolder: isFolder,
      ));
}
