import 'dart:io' as io;

import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'dart:async';

import '../models/folder.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class ReposCubit extends WatchSelf<ReposCubit> with OuiSyncAppLogger {
  final Map<String, RepoCubit> _repos = {};
  bool _isLoading = false;
  RepoCubit? _currentRepo;
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
;
  bool get isLoading => _isLoading;
  oui.Session get session => _session;
  String get appDir => _appDir;

  String? get currentRepoName => currentRepo?.name;

  Iterable<String> repositoryNames() => _repos.keys;

  RepoCubit? get currentRepo => _currentRepo;

  Folder? get currentFolder {
    return currentRepo?.currentFolder;
  }

  Iterable<RepoCubit> get repos => _repos.entries.map((entry) => entry.value);

  Future<void> setCurrent(RepoCubit? repo) async {
    if (currentRepo == repo) {
      return;
    }

    oui.NativeChannels.setRepository(repo?.handle);

    _subscription?.cancel();
    _subscription = null;

    _subscription = repo?.handle.subscribe(() => repo.getContent());
    await Settings.setDefaultRepo(repo?.name);

    _currentRepo = repo;
    changed();
  }

  Future<void> setCurrentByName(String? repoName) async {
    if (repoName == currentRepoName) {
      return;
    }

    setCurrent((repoName != null) ? _repos[repoName] : null);
  }

  RepoCubit? get(String name) {
    return _repos[name];
  }

  Future<void> put(RepoCubit newRepo, { bool setCurrent = false }) async {
    RepoCubit? oldRepo = _repos.remove(newRepo.name);

    var didChange = false;

    if (oldRepo == null) {
      didChange = true;
    } else {
      if (oldRepo != newRepo) {
        await oldRepo.close();
        didChange = true;
      }
    }

    _repos[newRepo.name] = newRepo;

    if (didChange) {
      if (setCurrent) {
        this.setCurrent(newRepo);
      } else {
        changed();
      }
    }
  }

  Future<String?> _forget(String name) async {
    if (currentRepoName == name) {
      loggy.app('Canceling subscription to $name');
      _subscription?.cancel();
      _subscription = null;
      _currentRepo = null;
    }

    final repo = _repos[name];

    if (repo == null) {
      return null;
    }

    final id = repo.id;
    await repo.close();
    _repos.remove(name);
    return id;
  }

  Future<void> close() async {
    // Make sure this function is idempotent, i.e. that calling it more than once
    // one after another won't change it's meaning nor it will crash.
    _currentRepo = null;

    _subscription?.cancel();
    _subscription = null;

    for (var repo in _repos.values) {
      await repo.close();
    }

    _repos.clear();

    changed();
  }

  Future<void> openRepository(String name, {String? password, oui.ShareToken? token, bool setCurrent = false }) async {
    _update(() { _isLoading = true; });

    final repo = await _open(name, password: password, token: token);

    if (repo != null) {
      await put(repo, setCurrent: setCurrent);
    } else {
      loggy.app('Failed to open repository $name');
    }

    _update(() { _isLoading = false; });
  }

  void unlockRepository({required String name, required String password}) async {
    _update(() { _isLoading = true; });

    final wasCurrent = currentRepoName == name;

    await _forget(name);

    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();

    if (!storeExist) {
      loggy.app('The repository store doesn\'t exist: $store');
      _update(() { _isLoading = false; });
      return;
    }

    try {
      final repo = await _getRepository(
        store: store,
        password: password,
        shareToken: null,
        exist: storeExist
      );

      await put(RepoCubit(name, repo), setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Unlocking of the repository $name failed', e, st);
    }

    _update(() { _isLoading = false; });
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

      final repo = await _open(oldName);

      if (repo == null) {
        await setCurrent(null);
      } else {
        await put(repo, setCurrent: wasCurrent);
      }

      return;
    }

    await Settings.setDefaultRepo(null);

    final repo = await _open(newName);

    if (repo == null) {
      await setCurrent(null);
    } else {
      await put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  void deleteRepository(String repositoryName) async {
    final wasCurrent = currentRepoName == repositoryName;

    final repoId = await _forget(repositoryName);

    if (repoId != null) {
      Settings.setDhtEnableStatus(repoId, null);
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

    final nextRepo = _repos.isNotEmpty ? _repos.values.first : null;

    setCurrent(nextRepo);
    await Settings.setDefaultRepo(nextRepo?.name);

    changed();
  }

  _buildStoreString(repositoryName) => '$_repositoriesDir/$repositoryName.db';

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

      return RepoCubit(name, repo);
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return null;
  }

  Future<oui.Repository> _getRepository({required String store, String? password, oui.ShareToken?  shareToken, required bool exist}) async {
    final oui.Repository repo;

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
