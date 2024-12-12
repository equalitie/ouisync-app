import 'dart:async';
import 'dart:collection';

import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' as oui;
import 'package:ouisync/state_monitor.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class ReposCubit extends WatchSelf<ReposCubit> with AppLogger {
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

  ReposCubit({
    required session,
    required nativeChannels,
    required settings,
    required this.cacheServers,
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

    final repos = await oui.Repository.list(_session);

    for (final repo in repos) {
      await _addRepo(repo);
    }

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

  Future<void> _addRepo(oui.Repository repo) async {
    // First open the repo in blind mode and with sync disabled, then try to unlock it with the
    // stored secret (if any) and only then enable sync. This is to avoid downloading unwanted
    // blocks.

    final cubit = await _createRepoCubit(repo);
    final authMode = cubit.state.authMode;

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
      final encryptedSecret = authMode.storedLocalSecret;

      if (encryptedSecret != null) {
        final secret = await encryptedSecret.decrypt(_settings.masterKey);
        await cubit.unlock(secret);
      } else {
        loggy.error('Failed to load secret key for ${repo.path}');
      }
    }

    await cubit.enableSync();

    await _addRepoEntry(OpenRepoEntry(cubit));
  }

  Future<void> _addRepoEntry(
    RepoEntry newRepo, {
    bool setCurrent = false,
  }) async {
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

  Future<RepoCubit> _createRepoCubit(oui.Repository repo) => RepoCubit.create(
        nativeChannels: _nativeChannels,
        navigation: navigation,
        bottomSheet: bottomSheet,
        repo: repo,
        session: _session,
        location: RepoLocation.fromDbPath(repo.path),
        cacheServers: cacheServers,
      );

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

    final oui.Repository repo;

    try {
      repo = await oui.Repository.open(_session, path: location.path);
    } on oui.AlreadyExists {
      showSnackBar(S.current.repositoryIsAlreadyImported);
      loggy.warning(
          'Same repository but from different location is already loaded');
      return;
    } catch (e, st) {
      loggy.error('Failed to open repository ${location.path}:', e, st);
      return;
    }

    await _addRepo(repo);

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
    await _addRepoEntry(LoadingRepoEntry(location), setCurrent: setCurrent);

    final localSecret = switch (setLocalSecret) {
      LocalSecretKeyAndSalt() => setLocalSecret,
      LocalPassword() => await passwordHasher.hashPassword(setLocalSecret),
    };

    SetLocalSecret readSecret;
    SetLocalSecret writeSecret;

    switch (await token?.accessMode) {
      case oui.AccessMode.blind:
        readSecret = LocalSecretKeyAndSalt.random();
        writeSecret = LocalSecretKeyAndSalt.random();
      case oui.AccessMode.read:
        readSecret = localSecret;
        writeSecret = LocalSecretKeyAndSalt.random();
      case oui.AccessMode.write:
        readSecret = LocalSecretKeyAndSalt.random();
        writeSecret = localSecret;
      case null:
        readSecret = LocalSecretKeyAndSalt.random();
        writeSecret = localSecret;
    }

    final repo = await oui.Repository.create(
      _session,
      path: location.path,
      readSecret: readSecret,
      writeSecret: writeSecret,
      token: token,
    );

    await repo.setSyncEnabled(true);
    await repo.setDhtEnabled(true);
    await repo.setPexEnabled(true);

    // Optionally enable cache server mirror.
    if (useCacheServers) {
      await cacheServers.setEnabled(repo, true);
    }

    final cubit = await _createRepoCubit(repo);

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

    final repoEntry = OpenRepoEntry(cubit);
    await _addRepoEntry(repoEntry);

    return repoEntry;
  }

  Future<void> deleteRepository(RepoLocation location) async {
    final wasCurrent = currentRepo?.location == location;
    final repoEntry = _repos.remove(location);

    if (repoEntry == null) {
      loggy.error('Failed to delete repository - not found');
      return;
    }

    await repoEntry.cubit?.delete();

    if (wasCurrent) {
      await setCurrent(null);
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

  void _update(void Function() changeState) {
    changeState();
    changed();
  }
}
