import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' as oui;
import 'package:ouisync/state_monitor.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/mounter.dart';
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

  final EntryBottomSheetCubit bottomSheet;
  final CacheServers cacheServers;
  final NavigationCubit navigation;
  final PasswordHasher passwordHasher;
  final Mounter mounter;

  ReposCubit({
    required session,
    required nativeChannels,
    required settings,
    required this.cacheServers,
    required this.mounter,
    EntryBottomSheetCubit? bottomSheet,
    NavigationCubit? navigation,
  })  : _session = session,
        _nativeChannels = nativeChannels,
        _settings = settings,
        bottomSheet = bottomSheet ?? EntryBottomSheetCubit(),
        navigation = navigation ?? NavigationCubit(),
        passwordHasher = PasswordHasher(session) {
    unawaited(_init());
  }

  Settings get settings => _settings;

  Future<void> _init() async {
    _update(() {
      _isLoading = true;
    });

    await Future.wait(
      _settings.repos.map((location) => _load(location)).toList(),
    );

    final defaultRepo =
        _settings.defaultRepo?.let((location) => _repos[location]);

    await setCurrent(defaultRepo);

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

    // We must not set repositories for which the user provides the password
    // as "default" because they must be indistinguishable from blind
    // repositories.
    final setDefault = switch (entry?.cubit?.state.authMode) {
      AuthModeKeyStoredOnDevice() || AuthModePasswordStoredOnDevice() => true,
      AuthModeBlindOrManual() => false,
      null => true,
    };

    if (setDefault) {
      await _settings.setDefaultRepo(entry?.location);
    }

    _currentRepo = entry;
    changed();
  }

  RepoEntry? get(RepoLocation location) {
    return _repos[location];
  }

  void showRepoList() {
    setCurrent(null);
  }

  Future<void> _load(RepoLocation location) async {
    // First open the repo in blind mode and with sync disabled, then try to unlock it with the
    // stored secret (if any) and only then enable sync. This is to avoid downloading unwanted
    // blocks.

    final repo = await _open(location);

    if (repo is OpenRepoEntry) {
      final authMode = repo.cubit.state.authMode;

      final unlock = switch (authMode) {
        AuthModeKeyStoredOnDevice(secureWithBiometrics: false) ||
        AuthModePasswordStoredOnDevice(secureWithBiometrics: false) =>
          true,
        AuthModeKeyStoredOnDevice() ||
        AuthModePasswordStoredOnDevice() ||
        AuthModeBlindOrManual() =>
          false,
      };

      if (unlock) {
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
    await _put(repo);
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

  @override
  Future<void> close() async {
    // Make sure this function is idempotent, i.e. that calling it more than once won't change it's
    // meaning nor it will crash.
    _currentRepo = null;

    final subscription = _subscription;
    _subscription = null;

    final repos = _repos.values.toList();
    _repos.clear();

    await subscription?.cancel();

    for (final repo in repos) {
      await repo.close();
    }

    await super.close();
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
      final existingEntry = _repos[oldLocation];

      if (existingEntry != null) {
        if (existingEntry is! MissingRepoEntry) {
          showSnackBar(S.current.repositoryIsAlreadyImported);
          loggy.app(
              "Same repository but from different location is already loaded");
          return;
        }

        // It's a MissingRepoEntry, we'll replace it with this new one.
        _repos.remove(oldLocation);
        await _settings.setRepoLocation(databaseId, location);
      }
    }

    final cubit = await RepoCubit.create(
      nativeChannels: _nativeChannels,
      navigation: navigation,
      bottomSheet: bottomSheet,
      repo: repo,
      location: location,
      cacheServers: cacheServers,
      mounter: mounter,
    );

    final entry = OpenRepoEntry(cubit);

    _repos[location] = entry;

    changed();
  }

  Future<RepoEntry> createRepository({
    required RepoLocation location,
    required SetLocalSecret setLocalSecret,
    required LocalSecretMode localSecretMode,
    oui.ShareToken? token,
    bool useCacheServers = false,
    bool setCurrent = false,
  }) async {
    await _put(LoadingRepoEntry(location), setCurrent: setCurrent);

    final localSecret = switch (setLocalSecret) {
      LocalSecretKeyAndSalt() => setLocalSecret,
      LocalPassword() => await passwordHasher.hashPassword(setLocalSecret),
    };

    final repo = await _create(
      location: location,
      localSecret: localSecret,
      localSecretMode: localSecretMode,
      token: token,
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
    final wasCurrent = currentRepo?.location == oldLocation;
    final credentials = await _repos[oldLocation]?.cubit?.credentials;

    await _forget(oldLocation);

    final renamed = await _renameRepositoryFiles(
      oldLocation: oldLocation,
      newName: newName,
    );

    if (!renamed) {
      loggy.app('The repository ${oldLocation.path} renaming failed');

      final repo = await _open(oldLocation);
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

    await _put(LoadingRepoEntry(newLocation), setCurrent: wasCurrent);

    final repo = await _open(newLocation);
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
    final databaseId = _settings.findRepoByLocation(location);

    if (databaseId == null) {
      loggy.app('Failed finding repo by location', 'Returned null');
      return;
    }

    await _forget(location);
    await _settings.forgetRepo(databaseId);

    final filesDeleted = await _deleteRepositoryFiles(location);

    if (!filesDeleted) {
      loggy.app(
          'The deletion of files for the repository "${location.path}" failed');

      await _put(
        ErrorRepoEntry(
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
    RepoLocation location, [
    LocalSecret? secret,
  ]) async {
    final store = location.path;

    try {
      if (!await io.File(store).exists()) {
        return MissingRepoEntry(
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
        nativeChannels: _nativeChannels,
        navigation: navigation,
        bottomSheet: bottomSheet,
        repo: repo,
        location: location,
        cacheServers: cacheServers,
        mounter: mounter,
      );

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.error('Initialization of the repository $store failed', e, st);
    }

    return ErrorRepoEntry(
      location,
      S.current.messageErrorOpeningRepo,
      S.current.messageErrorOpeningRepoDescription(store),
    );
  }

  Future<RepoEntry> _create({
    required RepoLocation location,
    required LocalSecretKeyAndSalt localSecret,
    required LocalSecretMode localSecretMode,
    oui.ShareToken? token,
    bool useCacheServers = false,
  }) async {
    final store = location.path;

    try {
      if (await io.File(store).exists()) {
        return ErrorRepoEntry(
          location,
          S.current.messageErrorRepositoryNameExist,
          null,
        );
      }

      SetLocalSecret readSecret;
      SetLocalSecret writeSecret;

      if (token != null) {
        switch (await token.mode) {
          case oui.AccessMode.blind:
            readSecret = LocalSecretKeyAndSalt.random();
            writeSecret = LocalSecretKeyAndSalt.random();
          case oui.AccessMode.read:
            readSecret = localSecret;
            writeSecret = LocalSecretKeyAndSalt.random();
          case oui.AccessMode.write:
            readSecret = LocalSecretKeyAndSalt.random();
            writeSecret = localSecret;
        }
      } else {
        readSecret = LocalSecretKeyAndSalt.random();
        writeSecret = localSecret;
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
        await cacheServers.setEnabled(repo, true);
      }

      final databaseId = DatabaseId(await repo.hexDatabaseId());

      final cubit = await RepoCubit.create(
        nativeChannels: _nativeChannels,
        navigation: navigation,
        bottomSheet: bottomSheet,
        repo: repo,
        location: location,
        cacheServers: cacheServers,
        mounter: mounter,
      );

      final authMode = switch (localSecretMode) {
        LocalSecretMode.manual => AuthModeBlindOrManual(),
        LocalSecretMode.manualStored => await AuthModeKeyStoredOnDevice.encrypt(
            _settings.masterKey,
            localSecret.key,
            keyOrigin: SecretKeyOrigin.manual,
            secureWithBiometrics: false,
          ),
        LocalSecretMode.manualSecuredWithBiometrics =>
          await AuthModeKeyStoredOnDevice.encrypt(
            _settings.masterKey,
            localSecret.key,
            keyOrigin: SecretKeyOrigin.manual,
            secureWithBiometrics: true,
          ),
        LocalSecretMode.randomStored => await AuthModeKeyStoredOnDevice.encrypt(
            _settings.masterKey,
            localSecret.key,
            keyOrigin: SecretKeyOrigin.random,
            secureWithBiometrics: false,
          ),
        LocalSecretMode.randomSecuredWithBiometrics =>
          await AuthModeKeyStoredOnDevice.encrypt(
            _settings.masterKey,
            localSecret.key,
            keyOrigin: SecretKeyOrigin.random,
            secureWithBiometrics: true,
          ),
      };

      await cubit.setAuthMode(authMode);

      await _settings.setRepoLocation(databaseId, location);

      return OpenRepoEntry(cubit);
    } catch (e, st) {
      loggy.app('Initialization of the repository $store failed', e, st);
    }

    return ErrorRepoEntry(
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
    for (final suffix in repoDbFileSuffixes) {
      final path = "${newLocation.path}$suffix";

      if (await io.File(path).exists()) {
        loggy.app("Destination file \"$path already exists\".");
        return false;
      }
    }

    for (final suffix in repoDbFileSuffixes) {
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

    for (final suffix in repoDbFileSuffixes) {
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

const repoDbFileSuffixes = ['', '-wal', '-shm'];
