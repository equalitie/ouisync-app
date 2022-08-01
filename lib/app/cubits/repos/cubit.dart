import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'dart:async';

import '../../models/repo_state.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../cubits.dart' as cubits;

import '../../models/folder_state.dart';

part 'state.dart';

class ReposCubit extends cubits.Watch<ReposState> with OuiSyncAppLogger {
  ReposCubit({
    required session,
    required appDir,
    required repositoriesDir
  }) :
    _session = session,
    _appDir = appDir,
    _repositoriesDir = repositoriesDir,
    super(ReposState())
  {}

  final oui.Session _session;
  final String _appDir;
  final String _repositoriesDir;

  oui.Session get session => _session;
  String get appDir => _appDir;

  cubits.Value<RepoState?> currentCubit() {
    return state.currentRepoCubit;
  }

  RepoState? current() {
    return state.currentRepo;
  }

  Future<void> openRepository(String name, {String? password, oui.ShareToken? token, bool setCurrent = false }) async {
    print("ReposCubit openRepository start $name");
    update((state) { state.isLoading = true; });

    final repo = await _open(name, password: password, token: token);

    if (repo != null) {
      await state.put(repo, setCurrent: setCurrent);
    } else {
      loggy.app('Failed to open repository $name');
    }

    print("ReposCubit openRepository end $name");
    update((state) { state.isLoading = false; });
  }

  void unlockRepository({required String name, required String password}) async {
    update((state) { state.isLoading = true; });

    final wasCurrent = state.currentRepo?.name == name;

    await state.remove(name);

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

      await state.put(RepoState(name, repository), setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Unlock repository $name exception', e, st);
    }

    update((state) { state.isLoading = false; });
  }

  Future<void> setCurrent(String? repoName) async {
    if (repoName == state.currentRepoName) {
      return;
    }

    RepoState? repo;

    if (repoName != null) {
      repo = state.get(repoName);
    }

    state.setCurrent(repo);

    changed();
  }

  void renameRepository(String oldName, String newName) async {
    final wasCurrent = state.currentRepo?.name == oldName;

    await state.remove(oldName);

    final renamed = await RepositoryHelper.renameRepositoryFiles(_repositoriesDir,
      oldName: oldName,
      newName: newName
    );

    if (!renamed) {
      loggy.app('The repository $oldName renaming failed');

      loggy.app('Initializing $oldName again...');
      final repo = await _open(oldName);

      if (repo == null) {
        await state.setCurrent(null);
      } else {
        await state.put(repo, setCurrent: wasCurrent);
      }

      changed();

      return;
    }

    await Settings.saveSetting(Constants.currentRepositoryKey, '');
    await RepositoryHelper.removeBitTorrentDHTStatusForRepo(oldName);

    final repo = await _open(newName);

    if (repo == null) {
      await state.setCurrent(null);
    } else {
      await state.put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  void deleteRepository(String repositoryName) async {
    final wasCurrent = state.currentRepo?.name == repositoryName;

    await state.remove(repositoryName);

    final deleted = await RepositoryHelper.deleteRepositoryFiles(
      _repositoriesDir,
      repositoryName: repositoryName
    );

    if (!deleted) {
      loggy.app('The repository $repositoryName deletion failed');

      loggy.app('Initializing $repositoryName again...');
      final repo = await _open(repositoryName);

      if (repo == null) {
        await state.setCurrent(null);
      } else {
        await state.put(repo, setCurrent: wasCurrent);
      }

      changed();

      return;
    }

    await Settings.saveSetting(Constants.currentRepositoryKey, '');
    await RepositoryHelper.removeBitTorrentDHTStatusForRepo(repositoryName);

    final latestRepositoryOrDefaultName = await RepositoryHelper.latestRepositoryOrDefault(null);

    if (latestRepositoryOrDefaultName.isEmpty) { /// No more repositories available
      changed();
      return;
    }

    RepoState? newDefaultRepository = state.get(latestRepositoryOrDefaultName);

    if (newDefaultRepository == null) { /// The new deafult repository has not been initialized / it's not in memory
      newDefaultRepository = await _open(latestRepositoryOrDefaultName);
    }

    await state.put(newDefaultRepository!);

    changed();
  }

  _buildStoreString(repositoryName) => '${_repositoriesDir}/$repositoryName.db';

  Future<void> close() async {
    await state.close();
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

  void update(void Function(ReposState) changeState) {
    changeState(state);
    changed();
  }
}
