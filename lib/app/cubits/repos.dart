import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/cubits/store_dirs.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/option.dart';
import '../utils/random.dart' show randomSalt, randomSecretKey;
import '../utils/utils.dart'
    show
        AnyExtension,
        AppLogger,
        CacheServers,
        MapExtension,
        None,
        Option,
        PasswordHasher,
        Settings,
        showSnackBar;
import 'cubits.dart';

class ReposState {
  final Map<RepoLocation, RepoEntry> repos;
  final RepoEntry? current;
  final bool isLoading;

  ReposState({
    Map<RepoLocation, RepoEntry>? repos,
    this.current,
    this.isLoading = false,
  }) : repos = repos ?? SplayTreeMap();

  ReposState copyWith({
    Map<RepoLocation, RepoEntry>? repos,
    Option<RepoEntry>? current,
    bool? isLoading,
  }) => ReposState(
    repos: repos ?? this.repos,
    current: current != null ? current.value : this.current,
    isLoading: isLoading ?? this.isLoading,
  );

  Iterable<RepoLocation> get locations => repos.keys;
  Iterable<String> get names => locations.map((location) => location.name);

  RepoEntry? findByInfoHash(String infoHash) =>
      repos.values.firstWhereOrNull((repo) => repo.infoHash == infoHash);
}

class ReposCubit extends Cubit<ReposState> with CubitActions, AppLogger {
  final Session _session;
  final Settings _settings;
  final MountCubit _mountCubit;

  final EntryBottomSheetCubit bottomSheet;
  final CacheServers cacheServers;
  final NavigationCubit navigation;
  final EntrySelectionCubit entriesSelection;
  final PasswordHasher passwordHasher;

  StreamSubscription<void>? _currentSubscription;
  StreamSubscription<void>? _storeDirsSubscription;

  ReposCubit({
    required session,
    required settings,
    required this.cacheServers,
    required MountCubit mountCubit,
    required StoreDirsCubit storeDirsCubit,
    EntryBottomSheetCubit? bottomSheet,
    NavigationCubit? navigation,
    EntrySelectionCubit? entriesSelection,
  }) : _session = session,
       _settings = settings,
       _mountCubit = mountCubit,
       bottomSheet = bottomSheet ?? EntryBottomSheetCubit(),
       navigation = navigation ?? NavigationCubit(),
       entriesSelection = entriesSelection ?? EntrySelectionCubit(),
       passwordHasher = PasswordHasher(session),
       super(ReposState()) {
    unawaited(_init(storeDirsCubit));
  }

  Future<void> _init(StoreDirsCubit storeDirsCubit) async {
    emitUnlessClosed(state.copyWith(isLoading: true));

    await _load();

    final current = _settings.defaultRepo?.let(
      (location) => state.repos[location],
    );
    await setCurrent(current);

    emitUnlessClosed(state.copyWith(isLoading: false));

    // Reload the repos when the store dirs change.
    _storeDirsSubscription = storeDirsCubit.stream
        .asyncMapSample((_) => _reload())
        .listen(null);
  }

  Future<void> _load() async {
    final repos = await _session.listRepositories();

    for (final repo in repos.values) {
      await _addRepo(repo);
    }
  }

  Future<void> _reload() async {
    loggy.debug('Reloading repositories');

    final currentLocation = state.current?.location;
    final currentSubscription = _currentSubscription;
    _currentSubscription = null;

    emit(
      state.copyWith(repos: SplayTreeMap(), current: None(), isLoading: true),
    );

    await currentSubscription?.cancel();
    await _load();

    if (currentLocation != null) {
      await setCurrent(state.repos[currentLocation]);
    }

    emit(state.copyWith(isLoading: false));
  }

  Session get session => _session;

  StateMonitor get rootStateMonitor => _session.rootStateMonitor;

  Future<ShareToken> createToken(String tokenString) =>
      session.validateShareToken(tokenString);

  Future<void> renameRepository(
    RepoLocation oldLocation,
    String newName,
  ) async {
    // The checks here should have been caught before calling this function,
    // thus only logging here.
    if (newName.isEmpty) {
      loggy.error("Not renaming: new name can't be empty");
      return;
    }

    final oldEntry = state.repos[oldLocation];

    if (oldEntry == null) {
      loggy.error("Not renaming: repository doesn't exist: $oldLocation");
      return;
    }

    if (oldEntry is! OpenRepoEntry) {
      loggy.error("Not renaming: repository is not open: $oldLocation");
      return;
    }

    final newLocation = oldEntry.location.rename(newName);

    if (newLocation == oldLocation) {
      loggy.error("Not renaming: new name same as old name: $oldLocation");
      return;
    }

    if (state.repos[newLocation] != null) {
      loggy.error("Not renaming: repository at $newLocation already exists");
      return;
    }

    RepoEntry newEntry = LoadingRepoEntry(newLocation);
    var newCurrent = state.current == oldEntry ? Some(newEntry) : null;

    emitUnlessClosed(
      state.copyWith(
        repos: state.repos
            .withRemoved(oldLocation)
            .withAdded(newLocation, newEntry),
        current: newCurrent,
      ),
    );

    try {
      await oldEntry.cubit.move(newLocation.path);
    } catch (e, st) {
      loggy.error(
        "Failed to move repository from $oldLocation to $newLocation: ",
        e,
        st,
      );

      // We don't know whether it was moved and then opening failed or whether
      // it wasn't moved at all. So we need to re-read the repos in the repo db
      // folder.
      emitUnlessClosed(ReposState(isLoading: true));
      await _load();
      emitUnlessClosed(state.copyWith(isLoading: false));

      rethrow;
    }

    newEntry = OpenRepoEntry(oldEntry.cubit);
    newCurrent = newCurrent != null ? Some(newEntry) : null;

    emitUnlessClosed(
      state.copyWith(
        repos: state.repos.withAdded(newLocation, newEntry),
        current: newCurrent,
      ),
    );
  }

  Future<void> setCurrent(RepoEntry? entry) async {
    if (state.current == entry) {
      return;
    }

    await _currentSubscription?.cancel();
    _currentSubscription = null;

    if (entry is OpenRepoEntry) {
      _currentSubscription = entry.cubit.autoRefresh();
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

    emitUnlessClosed(state.copyWith(current: Option.from(entry)));
  }

  void showRepoList() {
    setCurrent(null);
  }

  Future<void> _addRepo(Repository repo) async {
    // First open the repo in blind mode and with sync disabled, then try to unlock it with the
    // stored secret (if any) and only then enable sync. This is to avoid downloading unwanted
    // blocks.

    final cubit = await _createRepoCubit(repo);
    final authMode = cubit.state.authMode;

    final unlock = switch (authMode) {
      AuthModeKeyStoredOnDevice(secureWithBiometrics: false) ||
      AuthModePasswordStoredOnDevice(secureWithBiometrics: false) => true,
      AuthModeKeyStoredOnDevice() ||
      AuthModePasswordStoredOnDevice() ||
      AuthModeBlindOrManual() => false,
    };

    if (unlock) {
      final encryptedSecret = authMode.storedLocalSecret;

      if (encryptedSecret != null) {
        final secret = await encryptedSecret.decrypt(_settings.masterKey);
        await cubit.unlock(secret);
      } else {
        loggy.error(
          'Failed to load secret key for ${cubit.state.location.path}',
        );
      }
    }

    await cubit.enableSync();

    await _addRepoEntry(OpenRepoEntry(cubit));
  }

  Future<void> _addRepoEntry(RepoEntry newRepo) async {
    final oldRepo = state.repos[newRepo.location];

    if (oldRepo == newRepo) {
      return;
    }

    await oldRepo?.close();

    emitUnlessClosed(
      state.copyWith(repos: state.repos.withAdded(newRepo.location, newRepo)),
    );
  }

  Future<RepoCubit> _createRepoCubit(Repository repo) => RepoCubit.create(
    repo: repo,
    mountCubit: _mountCubit,
    navigation: navigation,
    entrySelection: entriesSelection,
    bottomSheet: bottomSheet,
    cacheServers: cacheServers,
  );

  @override
  Future<void> close() async {
    // Make sure this function is idempotent, i.e. that calling it more than once won't change it's
    // meaning nor it will crash.

    final repos = state.repos;

    emit(state.copyWith(repos: SplayTreeMap(), current: None()));

    await _currentSubscription?.cancel();
    _currentSubscription = null;

    await _storeDirsSubscription?.cancel();
    _storeDirsSubscription = null;

    for (final repo in repos.values) {
      await repo.close();
    }

    await super.close();
  }

  Future<void> importRepoFromLocation(RepoLocation location) async {
    if (state.repos.containsKey(location)) {
      // TODO:
      throw UnimplementedError('snackbar in cubit');
      //showSnackBar(S.current.repositoryIsAlreadyImported);

      return;
    }

    final Repository repo;

    try {
      repo = await _session.openRepository(path: location.path);
    } on AlreadyExists {
      // TODO:
      throw UnimplementedError('snackbar in cubit');
      //showSnackBar(S.current.repositoryIsAlreadyImported);

      loggy.warning(
        'Same repository but from different location is already loaded',
      );
      return;
    } catch (e, st) {
      loggy.error('Failed to open repository ${location.path}:', e, st);
      return;
    }

    await _addRepo(repo);
  }

  Future<RepoEntry> createRepository({
    required RepoLocation location,
    required SetLocalSecret setLocalSecret,
    required LocalSecretMode localSecretMode,
    ShareToken? token,
    bool useCacheServers = false,
    bool setCurrent = false,
  }) async {
    final entry = LoadingRepoEntry(location);
    await _addRepoEntry(entry);

    if (setCurrent) {
      await this.setCurrent(entry);
    }

    final localSecret = switch (setLocalSecret) {
      SetLocalSecretKeyAndSalt() => setLocalSecret,
      SetLocalSecretPassword(value: final password) =>
        await passwordHasher.hashPassword(password),
    };

    SetLocalSecret readSecret;
    SetLocalSecret writeSecret;

    SetLocalSecretKeyAndSalt randomLocalSecret() =>
        SetLocalSecretKeyAndSalt(key: randomSecretKey(), salt: randomSalt());

    switch (await token?.let(session.getShareTokenAccessMode)) {
      case AccessMode.blind:
        readSecret = randomLocalSecret();
        writeSecret = randomLocalSecret();
      case AccessMode.read:
        readSecret = localSecret;
        writeSecret = randomLocalSecret();
      case AccessMode.write:
        readSecret = randomLocalSecret();
        writeSecret = localSecret;
      case null:
        readSecret = randomLocalSecret();
        writeSecret = localSecret;
    }

    final repo = await _session.createRepository(
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

    if (setCurrent) {
      await this.setCurrent(repoEntry);
    }

    return repoEntry;
  }

  Future<void> deleteRepository(RepoLocation location) async {
    final entry = state.repos[location];
    if (entry == null) {
      return;
    }

    emitUnlessClosed(
      state.copyWith(
        repos: state.repos.withRemoved(location),
        current: state.current == entry ? None() : null,
      ),
    );

    await entry.cubit?.delete();
  }
}
