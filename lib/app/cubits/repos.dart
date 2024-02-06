import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../utils/settings/v0/secure_storage.dart';
import 'cubits.dart';

class ReposCubit extends WatchSelf<ReposCubit> with AppLogger {
  // NOTE: These can't be indexed by DatabaseId because one of the RepoEntry
  // instances is LoadingRepoEntry and when we're **creating** (as opposed to
  // opening an existing one) the repository we don't know the DatabaseId.
  final SplayTreeMap<String, RepoEntry> _repos =
      SplayTreeMap<String, RepoEntry>((key1, key2) => key1.compareTo(key2));
  bool _isLoading = false;
  RepoEntry? _currentRepo;
  final oui.Session _session;
  StreamSubscription<void>? _subscription;
  final Settings _settings;
  final NavigationCubit _navigation;

  ReposCubit({
    required session,
    required settings,
    required navigation,
  })  : _session = session,
        _settings = settings,
        _navigation = navigation;

  Settings get settings => _settings;

  Future<void> init() async {
    _update(() {
      _isLoading = true;
    });

    var futures = <Future>[];

    var defaultRepo = _settings.getDefaultRepo();

    for (final repo in _settings.repos()) {
      final repoName = repo.name;
      if (defaultRepo == null) {
        defaultRepo = repoName;
        await _settings.setDefaultRepo(repoName);
      }
      futures.add(_openRepository(repo, setCurrent: repoName == defaultRepo));
    }

    await Future.wait(futures);

    _update(() {
      _isLoading = false;
    });
  }

  bool get isLoading => _isLoading;
  oui.Session get session => _session;

  String? get currentRepoName => currentRepo?.name;

  Iterable<String> repositoryNames() => _repos.keys;

  bool get showList => _currentRepo == null;

  RepoEntry? get currentRepo => _currentRepo;

  StateMonitor get rootStateMonitor => _session.rootStateMonitor;

  Iterable<RepoEntry> get repos => _repos.entries.map((entry) => entry.value);

  Future<oui.ShareToken> createToken(String tokenString) =>
      oui.ShareToken.fromString(session, tokenString);

  Future<String?> validateTokenLink(String tokenLink) async {
    if (tokenLink.isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    final tokenUri = Uri.tryParse(tokenLink);
    if (tokenUri == null || !(tokenUri.isValidOuiSyncUri())) {
      return S.current.messageErrorTokenInvalid;
    }

    try {
      final shareToken = await oui.ShareToken.fromString(session, tokenLink);
      final existingRepo = findByInfoHash(await shareToken.infoHash);

      if (existingRepo != null) {
        return S.current.messageRepositoryAlreadyExist(existingRepo.name);
      }
    } catch (e) {
      return S.current.messageErrorTokenValidator;
    }

    return null;
  }

  RepoEntry? findByInfoHash(String infoHash) {
    try {
      return repos.firstWhere((repo) => repo.infoHash == infoHash);
    } on StateError {
      return null;
    }
  }

  Future<void> setCurrent(RepoEntry? entry) async {
    if (currentRepo == entry) {
      return;
    }

    entry?.maybeCubit?.setCurrent();

    await _subscription?.cancel();
    _subscription = null;

    if (entry is OpenRepoEntry) {
      _subscription = entry.cubit.autoRefresh();
    }

    await _settings.setDefaultRepo(entry?.name);

    _currentRepo = entry;
    changed();
  }

  Future<void> setCurrentByName(String? repoName) async {
    if (repoName == currentRepoName) {
      return;
    }

    await setCurrent((repoName != null) ? _repos[repoName] : null);
  }

  RepoEntry? get(String name) {
    return _repos[name];
  }

  void showRepoList() {
    _currentRepo = null;
    changed();
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
      if (setCurrent) {
        await this.setCurrent(newRepo);
      } else {
        changed();
      }
    }
  }

  Future<String?> _forget(String name) async {
    if (currentRepoName == name) {
      loggy.app('Canceling subscription to $name');
      await _subscription?.cancel();
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

    await _subscription?.cancel();
    _subscription = null;

    for (var repo in _repos.values) {
      await repo.close();
    }

    _repos.clear();

    changed();
  }

  Future<void> _openRepository(
    RepoSettings repoSettings, {
    bool setCurrent = false,
  }) async {
    String? password;

    if (repoSettings.hasPassword() &&
        !repoSettings.shouldCheckBiometricsBeforeUnlock()) {
      password = repoSettings.getPassword();

      if (password == null) {
        loggy
            .app('Failed to load password for ${repoSettings.location.path()}');
      }
    }

    final repo = await _open(repoSettings, password: password);

    if (password != null && repo is! OpenRepoEntry) {
      loggy.app('Failed to open repository ${repoSettings.location.path()}');
    }

    await _put(repo, setCurrent: setCurrent);
  }

  Future<RepoEntry> createRepository(RepoLocation location,
      {required String password,
      oui.ShareToken? token,
      required PasswordMode passwordMode,
      bool setCurrent = false}) async {
    await _put(LoadingRepoEntry(location), setCurrent: setCurrent);

    final repo = await _create(location,
        password: password, token: token, passwordMode: passwordMode);

    if (repo is! OpenRepoEntry) {
      loggy.app('Failed to create repository ${location.name}');
      return repo;
    }

    await _put(repo, setCurrent: setCurrent);
    return repo;
  }

  Future<oui.AccessMode?> unlockRepository(
    String repoName, {
    required String password,
  }) async {
    final wasCurrent = currentRepoName == repoName;

    final repoSettings = _settings.repoSettingsByName(repoName)!;

    await _forget(repoName);

    await _put(LoadingRepoEntry(repoSettings.location), setCurrent: wasCurrent);

    try {
      final repo = await _open(
        repoSettings,
        password: password,
      );

      if (repo is ErrorRepoEntry) {
        loggy.app('Failed to open repository: ${repoSettings.location.path()}');
        return null;
      }

      await _put(repo, setCurrent: wasCurrent);

      return repo.accessMode;
    } catch (e, st) {
      loggy.app(
          'Unlocking of the repository ${repoSettings.location.path()} failed',
          e,
          st);
      return null;
    }
  }

  Future<void> lockRepository(RepoSettings repoSettings) async {
    final wasCurrent = currentRepoName == repoSettings.name;

    await _forget(repoSettings.name);

    await _put(LoadingRepoEntry(repoSettings.location), setCurrent: wasCurrent);

    try {
      final repo = await _open(
        repoSettings,
      );

      if (repo is ErrorRepoEntry) {
        loggy.app('Failed to lock repository: ${repoSettings.name}');
        return;
      }

      await _put(repo, setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app('Locking the repository ${repoSettings.name} failed', e, st);
    }
  }

  Future<void> renameRepository(String oldName, String newName) async {
    if (!_repos.containsKey(oldName)) {
      loggy.error("Error renaming repository \"$oldName\": Does not exist");
      return;
    }

    if (_repos.containsKey(newName)) {
      loggy.error(
          "Error renaming repository \"$oldName\": Repository \"$newName\" already exists");
      return;
    }

    final repoSettings = _settings.repoSettingsByName(oldName)!;
    final wasCurrent = currentRepoName == oldName;
    final credentials = await _repos[oldName]?.maybeCubit?.credentials;

    await _forget(oldName);

    final renamed = await _renameRepositoryFiles(
      oldInfo: repoSettings.location,
      newName: newName,
    );

    if (!renamed) {
      loggy.app('The repository $oldName renaming failed');

      final repo = await _open(repoSettings);

      if (repo is ErrorRepoEntry) {
        await setCurrent(null);
      } else {
        await _put(repo, setCurrent: wasCurrent);
      }

      return;
    }

    await _settings.renameRepository(repoSettings, newName);

    await _put(LoadingRepoEntry(repoSettings.location), setCurrent: wasCurrent);

    final repo = await _open(repoSettings);

    if (credentials != null) {
      await repo.maybeCubit?.setCredentials(credentials);
    }

    if (repo is ErrorRepoEntry) {
      await setCurrent(null);
    } else {
      await _put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  Future<void> deleteRepository(RepoLocation location) async {
    final repoName = location.name;
    final wasCurrent = currentRepoName == repoName;
    final databaseId = _settings.repoSettingsByName(repoName)!.databaseId;

    final passwordDeleted =
        await SecureStorage(databaseId: databaseId).deletePassword();

    if (!passwordDeleted) return;

    await _forget(repoName);
    await _settings.forgetRepository(databaseId);

    final filesDeleted = await _deleteRepositoryFiles(location);

    if (!filesDeleted) {
      loggy.app('The deletion of files for the repository "$repoName" failed');

      await _put(
          ErrorRepoEntry(location, S.current.messageRepoDeletionFailed,
              S.current.messageRepoDeletionErrorDescription(repoName)),
          setCurrent: wasCurrent);

      changed();

      return;
    }

    final nextRepo = _repos.values.firstOrNull;

    await setCurrent(nextRepo);
    await _settings.setDefaultRepo(nextRepo?.name);

    changed();
  }

  Future<RepoEntry> _open(
    RepoSettings repoSettings, {
    String? password,
  }) async {
    final name = repoSettings.name;
    final store = repoSettings.location.path();

    try {
      if (!await io.File(store).exists()) {
        return MissingRepoEntry(
            repoSettings.location,
            S.current.messageRepoMissing,
            S.current.messageRepoMissingErrorDescription(name));
      }

      final repo = await oui.Repository.open(
        _session,
        store: store,
        password: password,
      );

      final cubit = await RepoCubit.create(
        repoSettings: repoSettings,
        session: _session,
        repo: repo,
        navigation: _navigation,
      );

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return ErrorRepoEntry(
        repoSettings.location,
        S.current.messageErrorOpeningRepo,
        S.current.messageErrorOpeningRepoDescription(name));
  }

  Future<RepoEntry> _create(
    RepoLocation location, {
    required String password,
    oui.ShareToken? token,
    required PasswordMode passwordMode,
  }) async {
    final name = location.name;
    final store = location.path();

    try {
      if (await io.File(store).exists()) {
        return ErrorRepoEntry(
            location, S.current.messageErrorRepositoryNameExist, null);
      }

      // TODO: readPassword and writePassword may be different, they can also
      // be null (together or separately). Consult documentation to
      // `Repository.create` for details.
      final repo = await oui.Repository.create(
        _session,
        store: store,
        readPassword: password,
        writePassword: password,
        shareToken: token,
      );

      // Enable server storage.
      // TODO: This should be configurable by the user
      try {
        await repo.mirror();
      } catch (e, st) {
        loggy.error(
            'Failed to create server mirror for repository $name:', e, st);
      }

      // Enable DHT and PEX by default
      await repo.setDhtEnabled(true);
      await repo.setPexEnabled(true);

      RepoSettings? repoSettings;

      if (passwordMode == PasswordMode.manual) {
        repoSettings = await _settings.addRepoWithUserProvidedPassword(location,
            databaseId: DatabaseId(await repo.hexDatabaseId()));
      } else {
        repoSettings = await _settings.addRepoWithPasswordStoredOnDevice(
            location,
            databaseId: DatabaseId(await repo.hexDatabaseId()),
            password: password,
            requireBiometricCheck: passwordMode == PasswordMode.bio);
      }

      final cubit = await RepoCubit.create(
        repoSettings: repoSettings!,
        session: _session,
        repo: repo,
        navigation: _navigation,
      );

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return ErrorRepoEntry(location, S.current.messageErrorCreatingRepository,
        S.current.messageErrorOpeningRepoDescription(name));
  }

  void _update(void Function() changeState) {
    changeState();
    changed();
  }

  Future<bool> _renameRepositoryFiles(
      {required RepoLocation oldInfo, required String newName}) async {
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

  Future<bool> _deleteRepositoryFiles(RepoLocation repoInfo) async {
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
