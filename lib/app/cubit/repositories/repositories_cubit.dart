import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

part 'repositories_state.dart';

class RepositoriesCubit extends Cubit<RepositoryPickerState> with OuiSyncAppLogger {
  RepositoriesCubit({required this.session}) : super(RepositoryPickerInitial());

  final Session session;

  /// Opens a repository in blind mode to allow synchronization, even before the
  /// user unlocks it.
  Future<Repository?> initRepository(String name) async {
    final store = await _buildStoreString(name);
    final storeExist = await io.File(store).exists();
    
    Repository? blindRepository;
    try {
      blindRepository = await _getRepository(
        session: this.session,
        store: store,
        password: '',
        shareToken: null,
        exist: storeExist
      );

      await RepositoryHelper.setRepoBitTorrentDHTStatus(blindRepository, name);
    } catch (e, st) {
      loggy.app('Init the repository $name exception', e, st);
    }

    return blindRepository;
  }

  void unlockRepository({required String name, required String password}) async {
    emit(RepositoryPickerLoading());
    
    final store = await _buildStoreString(name);
    final storeExist = await io.File(store).exists();
    
    if (!storeExist) {
      loggy.app('The repository store doesn\'t exist: $store');
      return;
    }

    try {
      final repository = await _getRepository(
        session: this.session,
        store: store,
        password: password,
        shareToken: null,
        exist: storeExist
      );

      await RepositoryHelper.setRepoBitTorrentDHTStatus(repository, name);

      emit(RepositoryPickerUnlocked(
        repository: repository,
        repositoryName: name,
        previousAccessMode: repository.accessMode
      ));
    } catch (e, st) {
      loggy.app('Unlock repository $name exception', e, st);
      emit(RepositoriesFailure());
    }
  }

  void openRepository({required String name, String? password, ShareToken? shareToken}) async {
    emit(RepositoryPickerLoading());

    final store = await _buildStoreString(name);
    final storeExist = await io.File(store).exists();
    
    try {
      final repository = await _getRepository(
        session: this.session,
        store: store,
        password: password,
        shareToken: shareToken,
        exist: storeExist
      );

      await RepositoryHelper.setRepoBitTorrentDHTStatus(repository, name);

      emit(RepositoryPickerSelection(NamedRepo(name, repository)));
    } catch (e, st) {
      loggy.app('Open repository $name exception', e, st);
      emit(RepositoriesFailure());
    }
  }

  void selectRepository(NamedRepo? namedRepo) async {
    if (namedRepo == null) {
      emit(RepositoryPickerInitial());
    } else {
      emit(RepositoryPickerSelection(namedRepo));
    }
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
    repositoriesService.remove(oldName); // 1

    await Settings.saveSetting(Constants.currentRepositoryKey, ''); // 2

    final reposDir = await Constants.reposPath;
    RepositoryHelper.renameRepositoryFiles(reposDir, 
      oldName: oldName,
      newName: newName
    ); // 3

    final repository = await initRepository(newName);

    emit(RepositoryPickerSelection(NamedRepo(newName, repository!))); // 6
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

    final reposDir = await Constants.reposPath;
    RepositoryHelper.deleteRepositoryFiles(
      reposDir,
      repositoryName: repositoryName
    ); // 3

    final latestRepositoryOrDefaultName = await RepositoryHelper
    .latestRepositoryOrDefault(null); // 4

    if (latestRepositoryOrDefaultName.isEmpty) { /// No more repositories available
      emit(RepositoryPickerInitial());
      return;
    }

    Repository? newDefaultRepository = repositoriesService
    .get(latestRepositoryOrDefaultName); // 5

    if (newDefaultRepository == null) { /// The new deafult repository has not been initialized / it's not in memory
      final repository = await initRepository(latestRepositoryOrDefaultName);
      newDefaultRepository = repository!;
    }

    repositoriesService.put(
      latestRepositoryOrDefaultName,
      newDefaultRepository
    );

    emit(RepositoryPickerSelection(
      NamedRepo(latestRepositoryOrDefaultName, newDefaultRepository))); // 6
  }

  Future<String> _buildStoreString(repositoryName) async {
    final reposDir = await Constants.reposPath;
    return join(reposDir, '$repositoryName.db');
    //  '${this.repositoriesDir}/$repositoryName.db';
  }

  Future<Repository> _getRepository({required Session session, required String store, String? password, ShareToken?  shareToken, required bool exist}) => 
    exist 
    ? Repository.open(session, store: store, password: password)
    : Repository.create(session, store: store, password: password!, shareToken: shareToken);
}
