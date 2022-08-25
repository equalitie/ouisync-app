import 'dart:io' as io;

import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'dart:async';

import '../models/folder.dart';
import '../models/repo_entry.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class ReposCubit extends WatchSelf<ReposCubit> with OuiSyncAppLogger {
  final Map<String, RepoEntry> _repos = {};
  bool _isLoading = false;
  RepoEntry? _currentRepo;
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
    _repositoriesDir = repositoriesDir ;

  Future<void> init(String? defaultRepo) async {
    _update(() { _isLoading = true; });

    var futures = <Future>[];

    await for (final repoName in await RepositoryHelper.localRepositoryNames(_repositoriesDir)) {
      futures.add(openRepository(repoName, setCurrent: repoName == defaultRepo));
    }

    _update(() { _isLoading = false; });

    await Future.wait(futures);
  }

  bool get isLoading => _isLoading;
  oui.Session get session => _session;
  String get appDir => _appDir;

  String? get currentRepoName => currentRepo?.name;

  Iterable<String> repositoryNames() => _repos.keys;

  RepoEntry? get currentRepo => _currentRepo;

  StateMonitor rootStateMonitor() => StateMonitor(_session.getRootStateMonitor());

  Folder? get currentFolder {
    return currentRepo?.currentFolder;
  }

  Iterable<RepoEntry> get repos => _repos.entries.map((entry) => entry.value);

  oui.ShareToken createToken(String tokenString) {
    return oui.ShareToken(session, tokenString);
  }

  RepoEntry? findById(String id) {
    for (final r in repos) {
      if (r.id == id) {
        return r;
      }
    }
    return null;
  }

  Future<void> setCurrent(RepoEntry? repo) async {
    if (currentRepo == repo) {
      return;
    }

    oui.NativeChannels.setRepository(repo?.maybeHandle);

    _subscription?.cancel();
    _subscription = null;

    if (repo is OpenRepoEntry) {
      _subscription = repo.handle.subscribe(() => repo.cubit.getContent());
    }

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

  RepoEntry? get(String name) {
    return _repos[name];
  }

  Future<void> _put(RepoEntry newRepo, { bool setCurrent = false }) async {
    RepoEntry? oldRepo = _repos.remove(newRepo.name);

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
      if (setCurrent || currentRepo == null) {
        await this.setCurrent(newRepo);
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
    await _put(LoadingRepoEntry(name), setCurrent: setCurrent);

    final repo = await _open(name, password: password, token: token);

    if (repo != null) {
      await _put(repo, setCurrent: setCurrent);
    } else {
      loggy.app('Failed to open repository $name');
    }
  }

  Future<void> unlockRepository({required String name, required String password}) async {
    final wasCurrent = currentRepoName == name;

    await _forget(name);

    await _put(LoadingRepoEntry(name), setCurrent: wasCurrent);

    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();

    if (!storeExist) {
      loggy.app('The repository store doesn\'t exist: $store');
      return;
    }

    try {
      final repo = await _getRepository(
        store: store,
        password: password,
        shareToken: null,
        exist: storeExist
      );

      await _put(OpenRepoEntry(RepoCubit(name, repo)), setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Unlocking of the repository $name failed', e, st);
    }
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
        await _put(repo, setCurrent: wasCurrent);
      }

      return;
    }

    await Settings.setDefaultRepo(null);

    final repo = await _open(newName);

    if (repo == null) {
      await setCurrent(null);
    } else {
      await _put(repo, setCurrent: wasCurrent);
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
        await _put(repo, setCurrent: wasCurrent);
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

  Future<OpenRepoEntry?> _open(String name, { String? password, oui.ShareToken? token }) async {
    final store = _buildStoreString(name);
    final storeExist = await io.File(store).exists();

    try {
      final repo = await _getRepository(
        store: store,
        password: password,
        shareToken: token,
        exist: storeExist
      );

      return OpenRepoEntry(RepoCubit(name, repo));
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
