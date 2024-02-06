import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/utils.dart';

class NavigationState {
  final DatabaseId? currentRepoId;
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
          currentRepoId: null,
          currentPath: '',
          isFolder: false,
        ));

  void current(DatabaseId databaseId, String path, bool isFolder) =>
      emit(NavigationState(
        currentRepoId: databaseId,
        currentPath: path,
        isFolder: isFolder,
      ));
}
