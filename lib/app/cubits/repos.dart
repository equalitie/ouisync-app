import 'dart:io' as io;

import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:path/path.dart' as p;
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

    await for (final repoName in _localRepositoryNames(_repositoriesDir)) {
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

    final repo = await _open(name, password: password, token: token, orCreate: true);

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

    try {
      final repo = await _open(
        name,
        password: password,
        token: null,
        orCreate: false
      );

      if (repo == null) {
        loggy.app('Failed to open repository: $name');
        return;
      }

      await _put(repo, setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Unlocking of the repository $name failed', e, st);
    }
  }

  void renameRepository(String oldName, String newName) async {
    final wasCurrent = currentRepoName == oldName;

    await _forget(oldName);

    final renamed = await _renameRepositoryFiles(_repositoriesDir,
      oldName: oldName,
      newName: newName
    );

    if (!renamed) {
      loggy.app('The repository $oldName renaming failed');

      final repo = await _open(oldName, orCreate: false);

      if (repo == null) {
        await setCurrent(null);
      } else {
        await _put(repo, setCurrent: wasCurrent);
      }

      return;
    }

    await Settings.renameRepository(oldName, newName);

    final repo = await _open(newName, orCreate: false);

    if (repo == null) {
      await setCurrent(null);
    } else {
      await _put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  void deleteRepository(String repositoryName) async {
    final wasCurrent = currentRepoName == repositoryName;

    await _forget(repositoryName);

    await Settings.forgetRepository(repositoryName);

    final deleted = await _deleteRepositoryFiles(
      _repositoriesDir,
      repositoryName: repositoryName
    );

    if (!deleted) {
      loggy.app('The repository $repositoryName deletion failed');

      loggy.app('Initializing $repositoryName again...');
      final repo = await _open(repositoryName, orCreate: false);

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

  Future<OpenRepoEntry?> _open(String name, { String? password, oui.ShareToken? token, required bool orCreate }) async {
    final store = _buildStoreString(name);

    try {
      late oui.Repository repo;

      if (await io.File(store).exists()) {
        repo = await oui.Repository.open(_session, store: store, password: password);
      } else {
        if (orCreate) {
          repo = await oui.Repository.create(_session, store: store, password: password!, shareToken: token);
        } else {
          return null;
        }
      }

      if (await Settings.getDhtEnableStatus(name, defaultValue: true)) {
        repo.enableDht();
      } else {
        repo.disableDht();
      }

      return OpenRepoEntry(RepoCubit(name, repo));
    }
    catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return null;
  }

  void _update(void Function() changeState) {
    changeState();
    changed();
  }

  static Stream<String> _localRepositoryNames(String location) async* {
    final dir = io.Directory(location);

    if (!await dir.exists()) {
      return;
    }

    await for (final file in dir.list()) {
      if (!file.path.endsWith(".db")) {
        continue;
      }

      yield p.basenameWithoutExtension(file.path);
    }
  }

  Future<bool> _renameRepositoryFiles(String repositoriesDir, {
    required String oldName,
    required String newName
  }) async {
    if (oldName == newName) return true;

    final dir = io.Directory(repositoriesDir);

    if (!await dir.exists()) {
      return false;
    }

    final exts = [ 'db', 'db-wal', 'db-shm' ];

    // Check the source db exists
    {
      final path = p.join(repositoriesDir, "$oldName.db");
      if (!await io.File(path).exists()) {
        loggy.app("Source database does not exist \"$path\".");
        return false;
      }
    }

    // Check the destination files don't exist
    for (final ext in exts) {
      final path = p.join(repositoriesDir, "$newName.$ext");
      if (await io.File(path).exists()) {
        loggy.app("Destination file \"$path already exists\".");
        return false;
      }
    }

    for (final ext in exts) {
      final srcPath = p.join(repositoriesDir, '$oldName.$ext');
      final srcFile = io.File(srcPath);

      if (!await srcFile.exists()) {
        continue;
      }

      final dstPath = p.join(repositoriesDir, '$newName.$ext');

      try {
        await srcFile.rename(dstPath);
      } catch (e, st) {
        loggy.app('Exception when renaming repo file "$srcPath" -> "$dstPath"', e, st);
      }
    }

    return true;
  }

  Future<bool> _deleteRepositoryFiles(String repositoriesDir, {
    required String repositoryName
  }) async {
    final dir = io.Directory(repositoriesDir);

    if (!await dir.exists()) {
      return false;
    }

    final exts = [ 'db', 'db-wal', 'db-shm' ];

    var success = true;

    for (final ext in exts) {
      final path = p.join(repositoriesDir, '$repositoryName.$ext');
      final file = io.File(path);

      if (!await file.exists()) {
        continue;
      }

      try {
        await file.delete();
      } catch (e, st) {
        loggy.app('Exception when removing repo file "$path"', e, st);
        success = false;
      }
    }

    return success;
  }
}
