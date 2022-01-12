import 'dart:io' as io;

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

  void openRepository({required String name, String? password}) async {
    emit(RepositoriesLoading());
    await Future.delayed(Duration(milliseconds: 500)); // TODO: Delay to allow the loading animation to show. Remove if not other use.

    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();
    
    try {
      final repository = await _getRepository(store: store, password: password, exist: storeExist);
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
    await Future.delayed(Duration(milliseconds: 500));// TODO: Delay to allow the loading animation to show. Remove if not other use.

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

  Future<Repository> _getRepository({required String store, String? password, required bool exist}) => 
    exist 
    ? Repository.open(this.session, store: store, password: password)
    : Repository.create(this.session, store: store, password: password!);
}
