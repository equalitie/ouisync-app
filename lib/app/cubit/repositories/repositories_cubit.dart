import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

part 'repositories_state.dart';

class RepositoriesCubit extends Cubit<RepositoriesState> {
  RepositoriesCubit({
    required this.session,
    required this.appDir,
    required this.repositoriesDir
  }) : super(RepositoriesInitial());

  final Session session;
  final String appDir;
  final String repositoriesDir;

  void openRepository(String name) async {
    emit(RepositoriesLoading());
    await Future.delayed(Duration(milliseconds: 500));

    final store = _buildStoreString(name);
    
    try {
      final repository = await _getRepository(store);
      emit(RepositoriesSelection(
        repository: repository,
        name: name
      ));
    } catch (e) {
      print('Exception opening the repository $name:\n${e.toString()}');
      emit(RepositoriesFailure());
    }
  }

  void selectRepository(Repository? repository, String name) async {
    emit(RepositoriesLoading());
    await Future.delayed(Duration(milliseconds: 500));

    if (repository == null) {
      emit(RepositoriesInitial());
      return;
    }

    emit(RepositoriesSelection(
        repository: repository,
        name: name
      ));
  }

  _buildStoreString(repositoryName) => '${this.repositoriesDir}/$repositoryName.db';

  Future<Repository> _getRepository(store) => Repository.open(this.session, store);
}
