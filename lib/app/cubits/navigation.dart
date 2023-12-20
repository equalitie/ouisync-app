import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/utils/log.dart';

class NavigationState {
  final String currentRepoId;
  final String currentPath;
  final bool isFolder;

  NavigationState({
    required this.currentRepoId,
    required this.currentPath,
    required this.isFolder,
  });
}

class NavigationCubit extends Cubit<NavigationState> with AppLogger {
  NavigationCubit()
      : super(NavigationState(
          currentRepoId: '',
          currentPath: '',
          isFolder: false,
        ));

  void current(String databaseId, String path, bool isFolder) =>
      emit(NavigationState(
        currentRepoId: databaseId,
        currentPath: path,
        isFolder: isFolder,
      ));
}
