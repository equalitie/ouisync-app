import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/repo_location.dart';
import '../utils/utils.dart';

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

class NavigationCubit extends Cubit<NavigationState> with AppLogger {
  NavigationCubit()
      : super(NavigationState(
          repoLocation: null,
          path: '',
          isFolder: false,
        ));

  void current(RepoLocation repoLocation, String path, bool isFolder) =>
      emit(NavigationState(
        repoLocation: repoLocation,
        path: path,
        isFolder: isFolder,
      ));
}
