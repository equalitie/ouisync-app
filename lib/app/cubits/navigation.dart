import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/models.dart' show RepoLocation;
import '../utils/utils.dart' show AppLogger;
import 'cubits.dart' show CubitActions;

class NavigationState {
  final RepoLocation? repoLocation;
  final String path;

  NavigationState({
    required this.repoLocation,
    required this.path,
  });
}

class NavigationCubit extends Cubit<NavigationState>
    with AppLogger, CubitActions {
  NavigationCubit() : super(NavigationState(repoLocation: null, path: ''));

  void current(RepoLocation repoLocation, String path) =>
      emitUnlessClosed(NavigationState(
        repoLocation: repoLocation,
        path: path,
      ));
}
