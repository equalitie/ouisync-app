import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'dart:io' as io;

import 'package:ouisync_plugin/native_channels.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class ReposCubit extends WatchSelf<ReposCubit> with AppLogger {
  // NOTE: These can't be indexed by DatabaseId because one of the RepoEntry
  // instances is LoadingRepoEntry and when we're **creating** (as opposed to
  // opening an existing one) the repository we don't know the DatabaseId.
  final _repos = SplayTreeMap<RepoLocation, RepoEntry>(
    (key1, key2) => key1.compareTo(key2),
  );
  bool _isLoading = false;
  RepoEntry? _currentRepo;
  final oui.Session _session;
  final NativeChannels _nativeChannels;
  StreamSubscription<void>? _subscription;
  final Settings _settings;
  final NavigationCubit _navigation;
  final PasswordHasher passwordHasher;

  ReposCubit({
    required session,
    required nativeChannels,
    required settings,
    required navigation,
  })  : _session = session,
        _nativeChannels = nativeChannels,
        _settings = settings,
        _navigation = navigation,
        passwordHasher = PasswordHasher(session);

  Settings get settings => _settings;

  Future<void> init() async {
    _update(() {
      _isLoading = true;
    });

    var futures = <Future>[];

    var defaultRepo = _settings.defaultRepo;

    for (final (databaseId, repoLocation) in _settings.repos) {
      if (defaultRepo == null) {
        defaultRepo = repoLocation;
        await _settings.setDefaultRepo(repoLocation);
      }

      futures.add(_load(
        databaseId,
        repoLocation,
        setCurrent: repoLocation == defaultRepo,
      ));
    }

    await Future.wait(futures);

    _update(() {
      _isLoading = false;
    });
  }

  bool get isLoading => _isLoading;
  oui.Session get session => _session;

  String? get currentRepoName => currentRepo?.name;
  RepoLocation? get currentRepoLocation => currentRepo?.location;

  Iterable<RepoLocation> repositoryLocations() => _repos.keys;
  Iterable<String> repositoryNames() =>
      repositoryLocations().map((location) => location.name);

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

    entry?.cubit?.setCurrent();

    await _subscription?.cancel();
    _subscription = null;

    if (entry is OpenRepoEntry) {
      _subscription = entry.cubit.autoRefresh();
    }

    await _settings.setDefaultRepo(entry?.location);

    _currentRepo = entry;
    changed();
  }

  Future<void> setCurrentByLocation(RepoLocation? repoLocation) async {
    if (repoLocation == currentRepo?.location) {
      return;
    }

    await setCurrent((repoLocation != null) ? _repos[repoLocation] : null);
  }

  RepoEntry? get(RepoLocation location) {
    return _repos[location];
  }

  void showRepoList() {
    _currentRepo = null;
    changed();
  }

  Future<void> _load(
    DatabaseId databaseId,
    RepoLocation location, {
    bool setCurrent = false,
  }) async {
    // First open the repo in blind mode and with sync disabled, then try to unlock it with the
    // stored secret (if any) and only then enable sync. This is to avoid downloading unwanted
    // blocks.

    final repo = await _open(databaseId, location);

    if (repo is OpenRepoEntry) {
      final authMode = repo.cubit.state.authMode;

      if (authMode.hasLocalSecret &&
          !authMode.shouldCheckBiometricsBeforeUnlock) {
        final secret = await repo.cubit.getLocalSecret(_settings.masterKey);

        if (secret != null) {
          await repo.cubit.unlock(secret);
        } else {
          loggy.error('Failed to load secret key for ${repo.location.path}');
        }
      }
    }

    if (repo is ErrorRepoEntry) {
      loggy.error('Failed to open repository ${repo.location.path}');
    }

    await repo.cubit?.enableSync();
    await _put(repo, setCurrent: setCurrent);
  }

  Future<void> _put(RepoEntry newRepo, {bool setCurrent = false}) async {
    RepoEntry? oldRepo = _repos.remove(newRepo.location);

    var didChange = false;

    if (oldRepo == null) {
      didChange = true;
    } else {
      if (oldRepo != newRepo) {
        await oldRepo.close();
        didChange = true;
      }
    }

    _repos[newRepo.location] = newRepo;

    if (didChange) {
      if (setCurrent) {
        await this.setCurrent(newRepo);
      } else {
        changed();
      }
    }
  }

  Future<String?> _forget(RepoLocation location) async {
    if (currentRepo?.location == location) {
      loggy.app('Canceling subscription to ${location.name}');
      await _subscription?.cancel();
      _subscription = null;
      _currentRepo = null;
    }

    final repo = _repos[location];

    if (repo == null) {
      return null;
    }

    final infoHash = repo.infoHash;
    await repo.close();
    _repos.remove(location);
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

  MapEntry<RepoLocation, RepoEntry>? repoById(DatabaseId id) {
    return _repos.entries.firstWhereOrNull((kv) => kv.value.databaseId == id);
  }

  Future<void> importRepoFromLocation(RepoLocation location) async {
    if (_repos.containsKey(location)) {
      showSnackBar(S.current.repositoryIsAlreadyImported);
      return;
    }

    oui.Repository repo;

    try {
      repo = await oui.Repository.open(_session, store: location.path);
    } catch (e) {
      loggy.app("Failed to open repository ${location.path}: $e");
      return;
    }

    await repo.setSyncEnabled(true);

    // Check for the situation where we alredy have an entry for the repository
    // but it's location has changed. If so, reuse the existing stored secrets
    // (if any).
    final databaseId = DatabaseId(await repo.hexDatabaseId());
    var oldLocation = _settings.getRepoLocation(databaseId);

    if (oldLocation == null) {
      await _settings.setRepoLocation(databaseId, location);
    } else {
      final existingEntry = repoById(databaseId);

      if (existingEntry != null) {
        if (existingEntry is! MissingRepoEntry) {
          showSnackBar(S.current.repositoryIsAlreadyImported);
          loggy.app(
              "Same repository but from different location is already loaded");
          return;
        }

        // It's a MissingRepoEntry, we'll replace it with this new one.
        _repos.remove(existingEntry.key);
        await _settings.setRepoLocation(databaseId, location);
      }
    }

    final cubit = await RepoCubit.create(
      session: _session,
      nativeChannels: _nativeChannels,
      settings: _settings,
      navigation: _navigation,
      repo: repo,
      databaseId: databaseId,
      location: location,
    );

    final entry = OpenRepoEntry(cubit);

    _repos[location] = entry;

    changed();
  }

  Future<RepoEntry> createRepository(
    RepoLocation location,
    SetLocalSecret secret, {
    oui.ShareToken? token,
    required PasswordMode passwordMode,
    bool useCacheServers = false,
    bool setCurrent = false,
  }) async {
    await _put(LoadingRepoEntry(null, location), setCurrent: setCurrent);

    LocalSecretKeyAndSalt localKey;

    switch (secret) {
      case LocalPassword():
        final salt = PasswordSalt.random();
        final key = await passwordHasher.hashPassword(secret, salt);
        localKey = LocalSecretKeyAndSalt(key, salt);
      case LocalSecretKeyAndSalt():
        localKey = secret;
    }

    final repo = await _create(
      location,
      localKey,
      token: token,
      passwordMode: passwordMode,
      useCacheServers: useCacheServers,
    );

    if (repo is! OpenRepoEntry) {
      loggy.app('Failed to create repository ${location.name}');
      return repo;
    }

    await _put(repo, setCurrent: setCurrent);
    return repo;
  }

  Future<void> renameRepository(
    RepoLocation oldLocation,
    String newName,
  ) async {
    if (!_repos.containsKey(oldLocation)) {
      loggy.error(
          "Error renaming repository \"${oldLocation.path}\": not tracked");
      return;
    }

    final newLocation = oldLocation.rename(newName);

    if (_repos.containsKey(newLocation)) {
      loggy.error(
          "Error renaming repository \"${oldLocation.path}\": Repository \"${newLocation.path}\" already exists");
      return;
    }

    final databaseId = _settings.findRepoByLocation(oldLocation)!;
    final wasCurrent = currentRepo?.databaseId == databaseId;
    final credentials = await _repos[oldLocation]?.cubit?.credentials;

    await _forget(oldLocation);

    final renamed = await _renameRepositoryFiles(
      oldLocation: oldLocation,
      newName: newName,
    );

    if (!renamed) {
      loggy.app('The repository ${oldLocation.path} renaming failed');

      final repo = await _open(databaseId, oldLocation);
      await repo.cubit?.enableSync();

      // TODO: restore credentials?

      if (repo is ErrorRepoEntry) {
        await setCurrent(null);
      } else {
        await _put(repo, setCurrent: wasCurrent);
      }

      return;
    }

    await _settings.renameRepo(databaseId, newLocation);

    await _put(
      LoadingRepoEntry(databaseId, newLocation),
      setCurrent: wasCurrent,
    );

    final repo = await _open(databaseId, newLocation);
    await repo.cubit?.enableSync();

    if (credentials != null) {
      await repo.cubit?.setCredentials(credentials);
    }

    if (repo is ErrorRepoEntry) {
      await setCurrent(null);
    } else {
      await _put(repo, setCurrent: wasCurrent);
    }

    changed();
  }

  Future<void> deleteRepository(RepoLocation location) async {
    final wasCurrent = currentRepo?.location == location;
    final databaseId = _settings.findRepoByLocation(location)!;

    await _forget(location);
    await _settings.forgetRepo(databaseId);

    final filesDeleted = await _deleteRepositoryFiles(location);

    if (!filesDeleted) {
      loggy.app(
          'The deletion of files for the repository "${location.path}" failed');

      await _put(
        ErrorRepoEntry(
          databaseId,
          location,
          S.current.messageRepoDeletionFailed,
          S.current.messageRepoDeletionErrorDescription(location.path),
        ),
        setCurrent: wasCurrent,
      );

      changed();

      return;
    }

    if (wasCurrent) {
      await setCurrent(null);
      await _settings.setDefaultRepo(null);
    }

    changed();
  }

  Future<void> ejectRepository(RepoLocation location) async {
    final wasCurrent = currentRepo?.location == location;
    final databaseId = _settings.findRepoByLocation(location)!;

    await _forget(location);
    await _settings.forgetRepo(databaseId);

    if (wasCurrent) {
      await setCurrent(null);
      await _settings.setDefaultRepo(null);
    }

    changed();
  }

  Future<RepoEntry> _open(
    DatabaseId databaseId,
    RepoLocation location, [
    LocalSecret? secret,
  ]) async {
    final store = location.path;

    try {
      if (!await io.File(store).exists()) {
        return MissingRepoEntry(
          databaseId,
          location,
          S.current.messageRepoMissing,
          S.current.messageRepoMissingErrorDescription(store),
        );
      }

      final repo = await oui.Repository.open(
        _session,
        store: store,
        secret: secret,
      );

      final cubit = await RepoCubit.create(
        session: _session,
        nativeChannels: _nativeChannels,
        settings: _settings,
        navigation: _navigation,
        repo: repo,
        databaseId: databaseId,
        location: location,
      );

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.error('Initialization of the repository $store failed', e, st);
    }

    return ErrorRepoEntry(
      databaseId,
      location,
      S.current.messageErrorOpeningRepo,
      S.current.messageErrorOpeningRepoDescription(store),
    );
  }

  Future<RepoEntry> _create(
    RepoLocation location,
    LocalSecretKeyAndSalt secret, {
    oui.ShareToken? token,
    required PasswordMode passwordMode,
    bool useCacheServers = false,
  }) async {
    final store = location.path;

    try {
      if (await io.File(store).exists()) {
        return ErrorRepoEntry(
          null,
          location,
          S.current.messageErrorRepositoryNameExist,
          null,
        );
      }

      LocalSecretKeyAndSalt readSecret;
      LocalSecretKeyAndSalt writeSecret;

      if (token != null) {
        switch (await token.mode) {
          case oui.AccessMode.blind:
            readSecret = LocalSecretKeyAndSalt.random();
            writeSecret = LocalSecretKeyAndSalt.random();
          case oui.AccessMode.read:
            readSecret = secret;
            writeSecret = LocalSecretKeyAndSalt.random();
          case oui.AccessMode.write:
            readSecret = LocalSecretKeyAndSalt.random();
            writeSecret = secret;
        }
      } else {
        readSecret = LocalSecretKeyAndSalt.random();
        writeSecret = secret;
      }

      // TODO: readSecret and writeSecret may be different, they can also
      // be null (together or separately). Consult documentation to
      // `Repository.create` for details.
      final repo = await oui.Repository.create(
        _session,
        store: store,
        readSecret: readSecret,
        writeSecret: writeSecret,
        shareToken: token,
      );

      await repo.setSyncEnabled(true);

      // Enable DHT and PEX by default
      await repo.setDhtEnabled(true);
      await repo.setPexEnabled(true);

      // Optionally enable cache server mirror.
      if (useCacheServers) {
        await repo.setCacheServersEnabled(true);
      }

      final databaseId = DatabaseId(await repo.hexDatabaseId());

      final cubit = await RepoCubit.create(
        session: _session,
        nativeChannels: _nativeChannels,
        settings: _settings,
        navigation: _navigation,
        repo: repo,
        databaseId: databaseId,
        location: location,
      );

      final authMode = switch (passwordMode) {
        PasswordMode.manual => AuthModeBlindOrManual(),
        PasswordMode.bio => await AuthModeKeyStoredOnDevice.encrypt(
            _settings.masterKey,
            secret.key,
            confirmWithBiometrics: true,
          ),
        PasswordMode.none => await AuthModeKeyStoredOnDevice.encrypt(
            _settings.masterKey,
            secret.key,
            confirmWithBiometrics: false,
          ),
      };

      await cubit.setAuthMode(authMode);

      await _settings.setRepoLocation(databaseId, location);

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $store failed', e, st);
    }

    return ErrorRepoEntry(
      null,
      location,
      S.current.messageErrorCreatingRepository,
      S.current.messageErrorOpeningRepoDescription(store),
    );
  }

  void _update(void Function() changeState) {
    changeState();
    changed();
  }

  Future<bool> _renameRepositoryFiles({
    required RepoLocation oldLocation,
    required String newName,
  }) async {
    final oldName = oldLocation.name;

    if (oldName == newName) return true;

    // Check the source db exists
    {
      if (!await io.File(oldLocation.path).exists()) {
        loggy.app("Source database does not exist \"${oldLocation.path}\".");
        return false;
      }
    }

    final newLocation = oldLocation.rename(newName);

    // Check the destination files don't exist
    for (final suffix in _dbFileSuffixes) {
      final path = "${newLocation.path}$suffix";

      if (await io.File(path).exists()) {
        loggy.app("Destination file \"$path already exists\".");
        return false;
      }
    }

    for (final suffix in _dbFileSuffixes) {
      final srcPath = "${oldLocation.path}$suffix";
      final srcFile = io.File(srcPath);

      if (!await srcFile.exists()) {
        continue;
      }

      final dstPath = "${newLocation.path}$suffix";

      try {
        await srcFile.rename(dstPath);
      } catch (e, st) {
        loggy.app('Exception when renaming repo file "$srcPath" -> "$dstPath"',
            e, st);
      }
    }

    return true;
  }

  Future<bool> _deleteRepositoryFiles(RepoLocation repoLocation) async {
    if (!await repoLocation.dir.exists()) {
      return false;
    }

    final primaryPath = repoLocation.path;

    var success = true;

    for (final suffix in _dbFileSuffixes) {
      final file = io.File('$primaryPath$suffix');

      if (!await file.exists()) {
        continue;
      }

      try {
        await file.delete();
      } catch (e, st) {
        loggy.app('Exception when removing repo file "${file.path}":', e, st);
        success = false;
      }
    }

    return success;
  }
}

const _dbFileSuffixes = ['', '-wal', '-shm'];
