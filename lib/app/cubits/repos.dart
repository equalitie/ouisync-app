import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';
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
  StreamSubscription<void>? _subscription;
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

    for (final repo in _settings.repos()) {
      final repoName = repo.name;
      if (defaultRepo == null) {
        defaultRepo = repoName;
        await _settings.setDefaultRepo(repoName);
      }
      futures.add(_openRepository(repo, setCurrent: repoName == defaultRepo));
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

  Future<void> setCurrent(RepoEntry? repo) async {
    if (currentRepo == repo) {
      return;
    }

    oui.NativeChannels.setRepository(repo?.maybeCubit?.handle);

    await _subscription?.cancel();
    _subscription = null;

    if (repo is OpenRepoEntry) {
      _subscription = repo.cubit.autoRefresh();
    }

    await _settings.setDefaultRepo(repo?.name);

    _currentRepo = repo;
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

  Future<void> _openRepository(SettingsRepoEntry settingsRepoEntry,
      {bool setCurrent = false}) async {
    await _put(LoadingRepoEntry(settingsRepoEntry.info),
        setCurrent: setCurrent);

    final password = await _tryGetSecurePassword(
        settingsRepoEntry.name, settingsRepoEntry.databaseId);

    final repo = await _open(settingsRepoEntry, password: password);
    if (repo is! OpenRepoEntry) {
      loggy.app('Failed to open repository ${settingsRepoEntry.info.path()}');
    }

    await _put(repo, setCurrent: setCurrent);
  }

  Future<String?> _tryGetSecurePassword(
      String repoName, String databaseId) async {
    final authenticationRequired = settings.getAuthenticationRequired(repoName);

    if (authenticationRequired != null && authenticationRequired == false) {
      final secureStorageResult = await SecureStorage.getRepositoryPassword(
          databaseId: databaseId, authenticationRequired: false);

      if (secureStorageResult.exception != null) {
        loggy.app(secureStorageResult.exception);

        return null;
      }

      final password = secureStorageResult.value;

      return password;
    }

    return null;
  }

  Future<RepoEntry> createRepository(RepoMetaInfo info,
      {required String password,
      oui.ShareToken? token,
      required bool authenticateWithBiometrics,
      bool setCurrent = false}) async {
    await _put(LoadingRepoEntry(info), setCurrent: setCurrent);

    final repo = await _create(info,
        password: password,
        token: token,
        authenticateWithBiometrics: authenticateWithBiometrics);

    if (repo is! OpenRepoEntry) {
      loggy.app('Failed to create repository ${info.name}');
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

    final settingsRepoEntry = _settings.entryByName(repoName)!;

    await _forget(repoName);

    await _put(LoadingRepoEntry(settingsRepoEntry.info),
        setCurrent: wasCurrent);

    try {
      final repo = await _open(
        settingsRepoEntry,
        password: password,
      );

      if (repo is ErrorRepoEntry) {
        loggy
            .app('Failed to open repository: ${settingsRepoEntry.info.path()}');
        return null;
      }

      await _put(repo, setCurrent: wasCurrent);

      return repo.accessMode;
    } catch (e, st) {
      loggy.app(
          'Unlocking of the repository ${settingsRepoEntry.info.path()} failed',
          e,
          st);
      return null;
    }
  }

  Future<void> lockRepository(SettingsRepoEntry settingsRepoEntry) async {
    final wasCurrent = currentRepoName == settingsRepoEntry.name;

    await _forget(settingsRepoEntry.name);

    await _put(LoadingRepoEntry(settingsRepoEntry.info),
        setCurrent: wasCurrent);

    try {
      final repo = await _open(
        settingsRepoEntry,
      );

      if (repo is ErrorRepoEntry) {
        loggy.app('Failed to lock repository: ${settingsRepoEntry.name}');
        return;
      }

      await _put(repo, setCurrent: wasCurrent);
    } catch (e, st) {
      loggy.app(
          'Locking the repository ${settingsRepoEntry.name} failed', e, st);
    }
  }

  void renameRepository(String oldName, String newName) async {
    if (!_repos.containsKey(oldName)) {
      print("Error renaming repository \"$oldName\": Does not exist");
      return;
    }

    if (_repos.containsKey(newName)) {
      print(
          "Error renaming repository \"$oldName\": Repository \"$newName\" already exists");
      return;
    }

    final settingsRepoEntry = _settings.entryByName(oldName)!;
    final wasCurrent = currentRepoName == oldName;

    await _forget(oldName);

    final renamed = await _renameRepositoryFiles(
        oldInfo: settingsRepoEntry.info, newName: newName);

    if (!renamed) {
      loggy.app('The repository $oldName renaming failed');

      final repo = await _open(settingsRepoEntry);

      if (repo is ErrorRepoEntry) {
        await setCurrent(null);
      } else {
        await _put(repo, setCurrent: wasCurrent);
      }

      return;
    }

    final newSettingsRepoEntry =
        await _settings.renameRepository(oldName, newName);

    final repo = await _open(newSettingsRepoEntry!);

    if (repo is ErrorRepoEntry) {
      await setCurrent(null);
    } else {
      await _put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  Future<void> deleteRepository(RepoMetaInfo info) async {
    final repoName = info.name;
    final wasCurrent = currentRepoName == repoName;
    final databaseId = _settings.getDatabaseId(repoName);

    final biometricsResult = await SecureStorage.deleteRepositoryPassword(
        databaseId: databaseId, authenticationRequired: false);

    if (biometricsResult.exception != null) {
      loggy.app(biometricsResult.exception);
      return;
    }

    await _forget(repoName);
    await _settings.forgetRepository(repoName);

    final deleted = await _deleteRepositoryFiles(info);

    if (!deleted) {
      loggy.app('The repository "$repoName" deletion failed');

      await _put(
          ErrorRepoEntry(info, S.current.messageRepoDeletionFailed,
              S.current.messageRepoDeletionErrorDescription(repoName)),
          setCurrent: wasCurrent);

      changed();

      return;
    }

    final nextRepo = _repos.isNotEmpty ? _repos.values.first : null;

    await setCurrent(nextRepo);
    await _settings.setDefaultRepo(nextRepo?.name);

    changed();
  }

  Future<RepoEntry> _open(SettingsRepoEntry settingsRepoEntry,
      {String? password}) async {
    final name = settingsRepoEntry.name;
    final store = settingsRepoEntry.info.path();

    try {
      if (!await io.File(store).exists()) {
        return MissingRepoEntry(
            settingsRepoEntry.info,
            S.current.messageRepoMissing,
            S.current.messageRepoMissingErrorDescription(name));
      }

      final repo =
          await oui.Repository.open(_session, store: store, password: password);

      final cubit = await RepoCubit.create(
          settingsRepoEntry: settingsRepoEntry,
          handle: repo,
          settings: _settings);

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return ErrorRepoEntry(
        settingsRepoEntry.info,
        S.current.messageErrorOpeningRepo,
        S.current.messageErrorOpeningRepoDescription(name));
  }

  Future<RepoEntry> _create(
    RepoMetaInfo info, {
    required String password,
    oui.ShareToken? token,
    required bool authenticateWithBiometrics,
  }) async {
    final name = info.name;
    final store = info.path();

    try {
      if (await io.File(store).exists()) {
        return ErrorRepoEntry(
            info, S.current.messageErrorRepositoryNameExist, null);
      }

      // TODO: readPassword and writePassword may be different, they can also
      // be null (together or separately). Consult documentation to
      // `Repository.create` for details.
      final repo = await oui.Repository.create(_session,
          store: store,
          readPassword: password,
          writePassword: password,
          shareToken: token);

      final settingsRepoEntry = await _settings.addRepo(info,
          databaseId: await repo.hexDatabaseId(),
          authenticateWithBiometrics: authenticateWithBiometrics);

      final cubit = await RepoCubit.create(
        settingsRepoEntry: settingsRepoEntry!,
        handle: repo,
        settings: _settings,
      );

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $name failed', e, st);
    }

    return ErrorRepoEntry(info, S.current.messageErrorCreatingRepository,
        S.current.messageErrorOpeningRepoDescription(name));
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
