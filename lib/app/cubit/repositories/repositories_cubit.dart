import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../services/services.dart';
import '../../utils/utils.dart';

part 'repositories_state.dart';

class RepositoriesCubit extends Cubit<RepositoryPickerState> {
  RepositoriesCubit({
    required this.session,
    required this.appDir,
    required this.repositoriesDir
  }) : super(RepositoryPickerInitial());

  final Session session;
  final String appDir;
  final String repositoriesDir;

  void openRepository({required String name, String? password, ShareToken? shareToken}) async {
    emit(RepositoryPickerLoading());
    await Future.delayed(Duration(milliseconds: 500)); // TODO: Delay to allow the loading animation to show. Remove if not other use.

    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();
    
    try {
      final repository = await _getRepository(
        store: store,
        password: password,
        shareToken: shareToken,
        exist: storeExist
      );

      emit(RepositoryPickerSelection(
        repository: repository,
        name: name
      ));
    } catch (e) {
      print('Exception opening the repository $name:\n${e.toString()}');
      emit(RepositoriesFailure());
    }
  }

  void selectRepository(Repository? repository, String name) async {
    emit(RepositoryPickerLoading());
    await Future.delayed(Duration(milliseconds: 500));// TODO: Delay to allow the loading animation to show. Remove if not other use.

    if (name.isEmpty) {
      emit(RepositoryPickerInitial());
      return;
    }

    emit(RepositoryPickerSelection(
        repository: repository,
        name: name
      ));
  }

  /// Renames a repository
  /// 
  /// 1. Remove the repiository from memory.
  /// 2. Reset the default repository setting.
  /// 3. Rename the *.db files in the local storage.
  /// 4. Get the new default repository from the remaining repositories, if any.
  /// 5. Get the default repository object from memory, if any.
  /// 6. Emits the event for selecting a new repository: this updates the
  ///    repository picker, and from there, the state in the main page. 
  void renameRepository(String oldName, String newName) async {
    final repositoriesService = RepositoriesService();
    repositoriesService.remove(newName); // 1

    await Settings.saveSetting(Constants.currentRepositoryKey, ''); // 2

    RepositoryHelper.renameRepositoryFiles(repositoriesDir, 
      oldName: oldName,
      newName: newName
    ); // 3

    final latestRepositoryOrDefaultName = await RepositoryHelper
    .latestRepositoryOrDefault(null); //4
    
    final newDefaultRepository = repositoriesService
    .get(latestRepositoryOrDefaultName); // 5

    emit(RepositoryPickerSelection(
      repository: newDefaultRepository!.repository,
      name: newDefaultRepository.name
    )); // 6
  }

  /// Deletes a repository
  /// 
  /// 1. Remove the repiository from memory.
  /// 2. Reset the default repository setting.
  /// 3. Deletes the *.db files from the local storage
  /// 4. Get the new default repository from the remaining repositories, if any.
  /// 5. Get the default repository object from memory, if any.
  /// 6. Emits the event for selecting a new repository: this updates the
  ///    repository picker, and from there, the state in the main page. 
  void deleteRepository(String repositoryName) async {
    final repositoriesService = RepositoriesService();
    repositoriesService.remove(repositoryName); // 1

    await Settings.saveSetting(Constants.currentRepositoryKey, ''); // 2

    RepositoryHelper.deleteRepositoryFiles(
      repositoriesDir,
      repositoryName: repositoryName
    ); // 3

    final latestRepositoryOrDefaultName = await RepositoryHelper
    .latestRepositoryOrDefault(null); // 4
    
    final newDefaultRepository = repositoriesService
    .get(latestRepositoryOrDefaultName); // 5

    emit(RepositoryPickerSelection(
      repository: newDefaultRepository!.repository,
      name: newDefaultRepository.name
    )); // 6
  }

  _buildStoreString(repositoryName) => '${this.repositoriesDir}/$repositoryName.db';

  Future<Repository> _getRepository({required String store, String? password, ShareToken?  shareToken, required bool exist}) => 
    exist 
    ? Repository.open(this.session, store: store, password: password)
    : Repository.create(this.session, store: store, password: password!, shareToken: shareToken);
}
