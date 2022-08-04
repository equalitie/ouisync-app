import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'dart:async';

import '../models/folder_state.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class ReposCubit extends WatchSelf<ReposCubit> with OuiSyncAppLogger {
  final Map<String, RepoCubit> _repos = Map();
  bool isLoading = false;
  final _currentRepoChange = Value<RepoCubit?>(null);
  final oui.Session _session;
  final String _appDir;
  final String _repositoriesDir;
  oui.Subscription? _subscription;

  ReposCubit({
    required session,
    required appDir,
    required repositoriesDir
  }) :
    _session = session,
    _appDir = appDir,
    _repositoriesDir = repositoriesDir
  {}

  oui.Session get session => _session;
  String get appDir => _appDir;

  Value<RepoCubit?> get currentRepoChange => _currentRepoChange;

  String? get currentRepoName => currentRepoChange.state?.name;

  Iterable<String> repositoryNames() => _repos.keys;

  RepoCubit? get currentRepo {
    final name = currentRepoName;
    (name == null) ? null : _repos[name];
  }

  FolderState? get currentFolder {
    return currentRepo?.state.currentFolder;
  }

  Iterable<RepoCubit> get repos => _repos.entries.map((entry) => entry.value);

  Future<void> setCurrent(RepoCubit? repo) async {
    if (currentRepoChange.state == repo) {
      return;
    }

    oui.NativeChannels.setRepository(repo?.state.handle);

    _subscription?.cancel();
    _subscription = null;

    _subscription = repo?.state.handle.subscribe(() => repo.getContent());
    await Settings.setDefaultRepo(repo?.name);

    _currentRepoChange.emit(repo);
    changed();
  }

  Future<void> setCurrentByName(String? repoName) async {
    if (repoName == currentRepoName) {
      return;
    }

    setCurrent((repoName != null) ? this.get(repoName) : null);
  }

  RepoCubit? get(String name) {
    return _repos[name];
  }

  Future<void> put(RepoCubit newRepo, { bool setCurrent = false }) async {
    RepoCubit? oldRepo = _repos.remove(newRepo.state.name);

    if (oldRepo != null && oldRepo != newRepo) {
      await oldRepo.state.close();
    }

    _repos[newRepo.state.name] = newRepo;

    if (setCurrent) {
      this.setCurrent(newRepo);
    }
  }

  Future<String?> _forget(String name) async {
    if (currentRepoName == name) {
      loggy.app('Canceling subscription to $name');
      _subscription?.cancel();
      _subscription = null;
      _currentRepoChange.emit(null);
    }

    final repo = _repos[name];

    if (repo == null) {
      return null;
    }

    final id = repo.id;
    await repo.state.close();
    _repos.remove(name);
    return id;
  }

  Future<void> close() async {
    // Make sure this function is idempotent, i.e. that calling it more than once
    // one after another won't change it's meaning nor it will crash.
    _currentRepoChange.emit(null);

    _subscription?.cancel();
    _subscription = null;

    for (var repo in _repos.values) {
      await repo.state.close();
    }

    _repos.clear();
  }

  Future<void> openRepository(String name, {String? password, oui.ShareToken? token, bool setCurrent = false }) async {
    print("ReposCubit openRepository start $name");
    _update(() { isLoading = true; });

    final repo = await _open(name, password: password, token: token);

    if (repo != null) {
      await this.put(repo, setCurrent: setCurrent);
    } else {
      loggy.app('Failed to open repository $name');
    }

    print("ReposCubit openRepository end $name");
    _update(() { isLoading = false; });
  }

  void unlockRepository({required String name, required String password}) async {
    _update(() { isLoading = true; });

    final wasCurrent = currentRepoName == name;

    await _forget(name);

    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();

    if (!storeExist) {
      loggy.app('The repository store doesn\'t exist: $store');
      _update(() { isLoading = false; });
      return;
    }

    try {
      final repo = await _getRepository(
        store: store,
        password: password,
        shareToken: null,
        exist: storeExist
      );

      await this.put(RepoCubit(RepoState(name, repo)), setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Unlocking of the repository $name failed', e, st);
    }

    _update(() { isLoading = false; });
  }

  void renameRepository(String oldName, String newName) async {
    final wasCurrent = currentRepoName == oldName;

    await _forget(oldName);

    final renamed = await RepositoryHelper.renameRepositoryFiles(_repositoriesDir,
      oldName: oldName,
      newName: newName
    );

    if (!renamed) {
      loggy.app('The repository $oldName renaming failed');

      loggy.app('Initializing $oldName again...');
      final repo = await _open(oldName);

      if (repo == null) {
        await setCurrent(null);
      } else {
        await this.put(repo, setCurrent: wasCurrent);
      }

      changed();

      return;
    }

    await Settings.setDefaultRepo(null);

    final repo = await _open(newName);

    if (repo == null) {
      await setCurrent(null);
    } else {
      await this.put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  void deleteRepository(String repositoryName) async {
    final wasCurrent = currentRepoName == repositoryName;

    final repo_id = await _forget(repositoryName);

    if (repo_id != null) {
      Settings.setDhtEnableStatus(repo_id, null);
    }

    final deleted = await RepositoryHelper.deleteRepositoryFiles(
      _repositoriesDir,
      repositoryName: repositoryName
    );

    if (!deleted) {
      loggy.app('The repository $repositoryName deletion failed');

      loggy.app('Initializing $repositoryName again...');
      final repo = await _open(repositoryName);

      if (repo == null) {
        await setCurrent(null);
      } else {
        await put(repo, setCurrent: wasCurrent);
      }

      changed();

      return;
    }

    await Settings.setDefaultRepo(null);

    final nextRepo = _repos.isNotEmpty ? _repos.values.first : null;

    setCurrent(nextRepo);
    await Settings.setDefaultRepo(nextRepo?.name);

    changed();
  }

  _buildStoreString(repositoryName) => '${_repositoriesDir}/$repositoryName.db';

  Future<RepoCubit?> _open(String name, { String? password, oui.ShareToken? token }) async {
    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();

    try {
      final repo = await _getRepository(
        store: store,
        password: password,
        shareToken: token,
        exist: storeExist
      );

      return RepoCubit(RepoState(name, repo));
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return null;
  }

  Future<oui.Repository> _getRepository({required String store, String? password, oui.ShareToken?  shareToken, required bool exist}) async {
    final repo;
   
    if (exist) {
      repo = await oui.Repository.open(_session, store: store, password: password);
    } else {
      repo = await oui.Repository.create(_session, store: store, password: password!, shareToken: shareToken);
    }

    if (await Settings.getDhtEnableStatus(repo.lowHexId(), defaultValue: true)) {
      repo.enableDht();
    } else {
      repo.disableDht();
    }

    return repo;
  }

  void _update(void Function() changeState) {
    changeState();
    changed();
  }
}
