import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class ReposCubit extends WatchSelf<ReposCubit> with OuiSyncAppLogger {
  final SplayTreeMap<String, RepoEntry> _repos =
      SplayTreeMap<String, RepoEntry>((key1, key2) => key1.compareTo(key2));
  bool _isLoading = false;
  RepoEntry? _currentRepo;
  final oui.Session _session;
  StreamSubscription<oui.RepositoryEvent>? _subscription;
  final Settings _settings;

  ReposCubit({required session, required settings})
      : _session = session,
        _settings = settings;

  Settings get settings => _settings;

  Future<void> init() async {
    _update(() {
      _isLoading = true;
    });

    var futures = <Future>[];

    var defaultRepo = _settings.getDefaultRepo();

    for (final repoInfo in _settings.repos()) {
      final repoName = repoInfo.name;
      if (defaultRepo == null) {
        defaultRepo = repoName;
        await _settings.setDefaultRepo(repoName);
      }
      futures
          .add(_openRepository(repoInfo, setCurrent: repoName == defaultRepo));
    }

    _update(() {
      _isLoading = false;
    });

    await Future.wait(futures);
  }

  bool get isLoading => _isLoading;
  oui.Session get session => _session;

  String? get currentRepoName => currentRepo?.name;

  Iterable<String> repositoryNames() => _repos.keys;

  RepoEntry? get currentRepo => _currentRepo;

  StateMonitor rootStateMonitor() =>
      StateMonitor(_session.getRootStateMonitor());

  Folder? get currentFolder {
    return currentRepo?.currentFolder;
  }

  Iterable<RepoEntry> get repos => _repos.entries.map((entry) => entry.value);

  oui.ShareToken createToken(String tokenString) {
    return oui.ShareToken(tokenString);
  }

  String? validateTokenLink(String tokenLink) {
    if (tokenLink.isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    final tokenUri = Uri.tryParse(tokenLink);
    if (tokenUri == null || !(tokenUri.isValidOuiSyncUri())) {
      return S.current.messageErrorTokenInvalid;
    }

    try {
      final shareToken = oui.ShareToken(tokenLink);
      final existingRepo = findByInfoHash(shareToken.infoHash);

      if (existingRepo != null) {
        return S.current.messageRepositoryAlreadyExist(existingRepo.name);
      }
    } catch (e) {
      return S.current.messageErrorTokenValidator;
    }

    return null;
  }

  RepoEntry? findByInfoHash(String infoHash) =>
      repos.firstWhereOrNull((repo) => repo.infoHash == infoHash);

  Future<void> setCurrent(RepoEntry? repo) async {
    if (currentRepo == repo) {
      return;
    }

    oui.NativeChannels.setRepository(repo?.maybeHandle);

    _subscription?.cancel();
    _subscription = null;

    if (repo is OpenRepoEntry) {
      _subscription = repo.handle.events.listen((_) => repo.cubit.getContent());
    }

    await _settings.setDefaultRepo(repo?.name);

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

  Future<void> _put(RepoEntry newRepo, {bool setCurrent = false}) async {
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

    final infoHash = repo.infoHash;
    await repo.close();
    _repos.remove(name);
    return infoHash;
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

  Future<void> _openRepository(RepoMetaInfo info,
      {String? password, bool setCurrent = false}) async {
    await _put(LoadingRepoEntry(info), setCurrent: setCurrent);

    final repo = await _open(info, password: password);

    if (repo != null) {
      await _put(repo, setCurrent: setCurrent);
    } else {
      loggy.app('Failed to open repository ${info.name}');
    }
  }

  Future<RepoEntry> createRepository(RepoMetaInfo info,
      {required String password,
      oui.ShareToken? token,
      bool setCurrent = false}) async {
    await _put(LoadingRepoEntry(info), setCurrent: setCurrent);

    await _settings.addRepo(info);

    final repo = await _create(info, password: password, token: token);
    if (repo is ErrorRepoEntry) {
      loggy.app('Failed to create repository ${info.name}');
      return repo;
    }

    await _put(repo, setCurrent: setCurrent);
    return repo;
  }

  Future<void> unlockRepository(String repoName,
      {required String password}) async {
    final wasCurrent = currentRepoName == repoName;

    final info = _settings.repoMetaInfo(repoName)!;

    await _forget(repoName);

    await _put(LoadingRepoEntry(info), setCurrent: wasCurrent);

    try {
      final repo = await _open(
        info,
        password: password,
      );

      if (repo == null) {
        loggy.app('Failed to open repository: ${info.name}');
        return;
      }

      await _put(repo, setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Unlocking of the repository ${info.name} failed', e, st);
    }
  }

  Future<void> lockRepository(RepoMetaInfo info) async {
    final wasCurrent = currentRepoName == info.name;

    await _forget(info.name);

    await _put(LoadingRepoEntry(info), setCurrent: wasCurrent);

    try {
      final repo = await _open(
        info,
      );

      if (repo == null) {
        loggy.app('Failed to lock repository: ${info.name}');
        return;
      }

      await _put(repo, setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Locking the repository ${info.name} failed', e, st);
    }
  }

  void renameRepository(String oldName, String newName) async {
    final oldInfo = _settings.repoMetaInfo(oldName)!;
    final newInfo = RepoMetaInfo.fromDirAndName(oldInfo.dir, newName);
    final wasCurrent = currentRepoName == oldName;

    await _forget(oldName);

    final renamed =
        await _renameRepositoryFiles(oldInfo: oldInfo, newName: newName);

    if (!renamed) {
      loggy.app('The repository $oldName renaming failed');

      final repo = await _open(oldInfo);

      if (repo == null) {
        await setCurrent(null);
      } else {
        await _put(repo, setCurrent: wasCurrent);
      }

      return;
    }

    await _settings.renameRepository(oldName, newName);

    final repo = await _open(newInfo);

    if (repo == null) {
      await setCurrent(null);
    } else {
      await _put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  void deleteRepository(RepoMetaInfo info) async {
    final repoName = info.name;
    final wasCurrent = currentRepoName == repoName;

    await _forget(repoName);
    await _settings.forgetRepository(repoName);

    final deleted = await _deleteRepositoryFiles(info);

    // TODO: Instead of trying to reopen this repository, we should create a new
    // subclass of RepoEntry and tell the user that there that deletion failed.
    // After restarting the app, if the main `.db` file still exists, we should
    // try to open it as normal, but if the main `.db` file has been deleted while
    // the supporting files still exist, we should still show the user the new
    // subclass of RepoEntry.
    if (!deleted) {
      loggy.app('The repository $repoName deletion failed');

      loggy.app('Initializing $repoName again...');
      final repo = await _open(info);

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
    await _settings.setDefaultRepo(nextRepo?.name);

    changed();
  }

  Future<OpenRepoEntry?> _open(RepoMetaInfo info, {String? password}) async {
    final name = info.name;
    final store = info.path();

    try {
      if (!await io.File(store).exists()) {
        return null;
      }

      final repo =
          await oui.Repository.open(_session, store: store, password: password);

      final cubit =
          RepoCubit(metaInfo: info, handle: repo, settings: _settings);
      cubit.loadSettings();

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return null;
  }

  Future<RepoEntry> _create(
    RepoMetaInfo info, {
    required String password,
    oui.ShareToken? token,
  }) async {
    final name = info.name;
    final store = info.path();

    try {
      if (await io.File(store).exists()) {
        return ErrorRepoEntry(info, S.current.messageErrorRepositoryNameExist);
      }

      final repo = await oui.Repository.create(_session,
          store: store, password: password, shareToken: token);

      final cubit =
          RepoCubit(metaInfo: info, handle: repo, settings: _settings);
      cubit.loadSettings();

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return ErrorRepoEntry(info, S.current.messageErrorCreatingRepository);
  }

  void _update(void Function() changeState) {
    changeState();
    changed();
  }

  Future<bool> _renameRepositoryFiles(
      {required RepoMetaInfo oldInfo, required String newName}) async {
    final oldName = oldInfo.name;

    if (oldName == newName) return true;

    final dir = oldInfo.dir;

    if (!await dir.exists()) {
      return false;
    }

    final exts = ['db', 'db-wal', 'db-shm'];

    // Check the source db exists
    {
      final path = p.join(dir.path, "$oldName.db");
      if (!await io.File(path).exists()) {
        loggy.app("Source database does not exist \"$path\".");
        return false;
      }
    }

    // Check the destination files don't exist
    for (final ext in exts) {
      final path = p.join(dir.path, "$newName.$ext");
      if (await io.File(path).exists()) {
        loggy.app("Destination file \"$path already exists\".");
        return false;
      }
    }

    for (final ext in exts) {
      final srcPath = p.join(dir.path, '$oldName.$ext');
      final srcFile = io.File(srcPath);

      if (!await srcFile.exists()) {
        continue;
      }

      final dstPath = p.join(dir.path, '$newName.$ext');

      try {
        await srcFile.rename(dstPath);
      } catch (e, st) {
        loggy.app('Exception when renaming repo file "$srcPath" -> "$dstPath"',
            e, st);
      }
    }

    return true;
  }

  Future<bool> _deleteRepositoryFiles(RepoMetaInfo repoInfo) async {
    final dir = repoInfo.dir;

    if (!await dir.exists()) {
      return false;
    }

    final exts = ['db', 'db-wal', 'db-shm'];

    var success = true;

    for (final ext in exts) {
      final path = repoInfo.path(ext: ext);
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
