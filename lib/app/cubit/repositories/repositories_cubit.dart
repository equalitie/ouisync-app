import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../../models/main_state.dart';
import '../../models/repo_state.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

part 'repositories_state.dart';

class RepositoriesCubit extends Cubit<RepositoriesChanged> with OuiSyncAppLogger {
  RepositoriesCubit({
    required session,
    required appDir,
    required repositoriesDir
  }) :
    _session = session,
    _appDir = appDir,
    _repositoriesDir = repositoriesDir,
    _mainState = MainState(),
    super(RepositoriesChanged())
  {}

  final oui.Session _session;
  final String _appDir;
  final String _repositoriesDir;
  final MainState _mainState;

  oui.Session get session => _session;
  String get appDir => _appDir;
  MainState get mainState => _mainState;

  RepoState? current() {
    return _mainState.currentRepo;
  }

  Future<void> openRepository(String name, {String? password, oui.ShareToken? token, bool setCurrent = false }) async {
    print("Cubit openRepository start $name");
    update((state) { state.isLoading = true; });

    final repo = await _open(name, password: password, token: token);

    if (repo != null) {
      await _mainState.put(repo, setCurrent: setCurrent);
    } else {
      loggy.app('Failed to open repository $name');
    }

    print("Cubit openRepository end $name");
    update((state) { state.isLoading = false; });
  }

  void unlockRepository({required String name, required String password}) async {
    update((state) { state.isLoading = true; });

    final wasCurrent = _mainState.currentRepo?.name == name;

    await _mainState.remove(name);

    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();

    if (!storeExist) {
      loggy.app('The repository store doesn\'t exist: $store');
      update((state) { state.isLoading = false; });
      return;
    }

    try {
      final repository = await _getRepository(
        store: store,
        password: password,
        shareToken: null,
        exist: storeExist
      );

      await RepositoryHelper.setRepoBitTorrentDHTStatus(repository, name);

      await _mainState.put(RepoState(name, repository), setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Unlock repository $name exception', e, st);
    }

    update((state) { state.isLoading = false; });
  }

  Future<void> setCurrent(String? repoName) async {
    if (repoName == _mainState.currentRepoName) {
      return;
    }

    RepoState? repo;

    if (repoName != null) {
      repo = _mainState.get(repoName);
    }

    _mainState.setCurrent(repo);

    emitChange();
  }

  void renameRepository(String oldName, String newName) async {
    final wasCurrent = _mainState.currentRepo?.name == oldName;

    await _mainState.remove(oldName);

    final renamed = await RepositoryHelper.renameRepositoryFiles(_repositoriesDir,
      oldName: oldName,
      newName: newName
    );

    if (!renamed) {
      loggy.app('The repository $oldName renaming failed');

      loggy.app('Initializing $oldName again...');
      final repo = await _open(oldName);

      if (repo == null) {
        await _mainState.setCurrent(null);
      } else {
        await _mainState.put(repo, setCurrent: wasCurrent);
      }

      emitChange();

      return;
    }

    await Settings.saveSetting(Constants.currentRepositoryKey, '');
    await RepositoryHelper.removeBitTorrentDHTStatusForRepo(oldName);

    final repo = await _open(newName);

    if (repo == null) {
      await _mainState.setCurrent(null);
    } else {
      await _mainState.put(repo, setCurrent: wasCurrent);
    }

    emitChange();
  }

  void deleteRepository(String repositoryName) async {
    final wasCurrent = _mainState.currentRepo?.name == repositoryName;

    await _mainState.remove(repositoryName);

    final deleted = await RepositoryHelper.deleteRepositoryFiles(
      _repositoriesDir,
      repositoryName: repositoryName
    );

    if (!deleted) {
      loggy.app('The repository $repositoryName deletion failed');

      loggy.app('Initializing $repositoryName again...');
      final repo = await _open(repositoryName);

      if (repo == null) {
        await _mainState.setCurrent(null);
      } else {
        await _mainState.put(repo, setCurrent: wasCurrent);
      }

      emitChange();

      return;
    }

    await Settings.saveSetting(Constants.currentRepositoryKey, '');
    await RepositoryHelper.removeBitTorrentDHTStatusForRepo(repositoryName);

    final latestRepositoryOrDefaultName = await RepositoryHelper.latestRepositoryOrDefault(null);

    if (latestRepositoryOrDefaultName.isEmpty) { /// No more repositories available
      emitChange();
      return;
    }

    RepoState? newDefaultRepository = _mainState.get(latestRepositoryOrDefaultName);

    if (newDefaultRepository == null) { /// The new deafult repository has not been initialized / it's not in memory
      newDefaultRepository = await _open(latestRepositoryOrDefaultName);
    }

    await _mainState.put(newDefaultRepository!);

    emitChange();
  }

  _buildStoreString(repositoryName) => '${_repositoriesDir}/$repositoryName.db';

  Future<void> close() async {
    await _mainState.close();
  }

  Future<RepoState?> _open(String name, { String? password, oui.ShareToken? token }) async {
    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();

    try {
      final repository = await _getRepository(
        store: store,
        password: password,
        shareToken: token,
        exist: storeExist
      );

      await RepositoryHelper.setRepoBitTorrentDHTStatus(repository, name);
      return RepoState(name, repository);
    } catch (e, st) {
      loggy.app('Init the repository $name exception', e, st);
    }

    return null;
  }

  Future<oui.Repository> _getRepository({required String store, String? password, oui.ShareToken?  shareToken, required bool exist}) =>
    exist 
    ? oui.Repository.open(_session, store: store, password: password)
    : oui.Repository.create(_session, store: store, password: password!, shareToken: shareToken);

  void update(void Function(MainState) changeState) {
    changeState(_mainState);
    emitChange();
  }


  void emitChange() {
    emit(RepositoriesChanged());
  }
}
