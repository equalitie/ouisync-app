import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

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

  void renameRepository({
    Repository? repository,
    required String oldName,
    required String newName
  }) async {
    emit(RepositoryPickerSelection(
      repository: null,
      name: ''
    ));

    final repositoriesDir = await Settings.readSetting(Constants.repositoriesDirKey);
    final files = await io.Directory(repositoriesDir).list().where((element) => element.path.contains(oldName)).toList();
    files.forEach((element) { element.renameSync('$repositoriesDir/$newName.db'); });

    print(io.Directory(repositoriesDir).listSync());

    emit(RepositoryPickerSelection(
      repository: null,
      name: newName
    ));
  }


  _buildStoreString(repositoryName) => '${this.repositoriesDir}/$repositoryName.db';

  Future<Repository> _getRepository({required String store, String? password, ShareToken?  shareToken, required bool exist}) => 
    exist 
    ? Repository.open(this.session, store: store, password: password)
    : Repository.create(this.session, store: store, password: password!, shareToken: shareToken);
}
