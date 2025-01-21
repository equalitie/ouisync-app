import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' as oui;
import 'package:ouisync/state_monitor.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class ReposState {
  final Map<RepoLocation, RepoEntry> repos;
  final RepoLocation? current;
  final bool isLoading;

  ReposState({
    Map<RepoLocation, RepoEntry>? repos,
    this.current,
    this.isLoading = false,
  }) : repos = repos ?? SplayTreeMap();

  ReposState copyWith({
    Map<RepoLocation, RepoEntry>? repos,
    Option<RepoLocation>? current,
    bool? isLoading,
  }) =>
      ReposState(
        repos: repos ?? this.repos,
        current: current != null ? current.value : this.current,
        isLoading: isLoading ?? this.isLoading,
      );

  Iterable<RepoLocation> get locations => repos.keys;
  Iterable<String> get names => locations.map((location) => location.name);

  RepoEntry? get currentEntry => current?.let((current) => repos[current]);

  RepoEntry? findByInfoHash(String infoHash) =>
      repos.values.firstWhereOrNull((repo) => repo.infoHash == infoHash);
}

class ReposCubit extends Cubit<ReposState> with CubitActions, AppLogger {
  final oui.Session _session;
  final NativeChannels _nativeChannels;
  StreamSubscription<void>? _subscription;
  final Settings _settings;

  final EntryBottomSheetCubit bottomSheet;
  final CacheServers cacheServers;
  final NavigationCubit navigation;
  final EntrySelectionCubit entriesSelection;
  final PasswordHasher passwordHasher;

  ReposCubit({
    required session,
    required nativeChannels,
    required settings,
    required this.cacheServers,
    EntryBottomSheetCubit? bottomSheet,
    NavigationCubit? navigation,
    EntrySelectionCubit? entriesSelection,
  })  : _session = session,
        _nativeChannels = nativeChannels,
        _settings = settings,
        bottomSheet = bottomSheet ?? EntryBottomSheetCubit(),
        navigation = navigation ?? NavigationCubit(),
        entriesSelection = entriesSelection ?? EntrySelectionCubit(),
        passwordHasher = PasswordHasher(session),
        super(ReposState()) {
    unawaited(_init());
  }

  Future<void> _init() async {
    emitUnlessClosed(state.copyWith(isLoading: true));

    final repos = await oui.Repository.list(_session);

    for (final repo in repos) {
      await _addRepo(repo);
    }

    await setCurrent(_settings.defaultRepo);

    emitUnlessClosed(state.copyWith(isLoading: false));
  }

  oui.Session get session => _session;

  StateMonitor get rootStateMonitor => _session.rootStateMonitor;

  Future<oui.ShareToken> createToken(String tokenString) =>
      oui.ShareToken.fromString(session, tokenString);

  Future<void> setCurrent(RepoLocation? location) async {
    if (state.current == location) {
      return;
    }

    final entry = location != null ? state.repos[location] : null;

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
      await _settings.setDefaultRepo(location);
    }

    emitUnlessClosed(state.copyWith(current: Option.from(location)));
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

  Future<RepoCubit> _createRepoCubit(oui.Repository repo) => RepoCubit.create(
        nativeChannels: _nativeChannels,
        repo: repo,
        session: _session,
        location: RepoLocation.fromDbPath(repo.path),
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
    final subscription = _subscription;

    emit(state.copyWith(repos: SplayTreeMap(), current: None()));

    await subscription?.cancel();

    for (final repo in repos.values) {
      await repo.close();
    }

    await super.close();
  }

  Future<void> importRepoFromLocation(RepoLocation location) async {
    if (state.repos.containsKey(location)) {
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
  }

  Future<RepoEntry> createRepository({
    required RepoLocation location,
    required SetLocalSecret setLocalSecret,
    required LocalSecretMode localSecretMode,
    oui.ShareToken? token,
    bool useCacheServers = false,
    bool setCurrent = false,
  }) async {
    await _addRepoEntry(LoadingRepoEntry(location));

    if (setCurrent) {
      await this.setCurrent(location);
    }

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
    final entry = state.repos[location];
    if (entry == null) {
      return;
    }

    emitUnlessClosed(state.copyWith(
      repos: state.repos.withRemoved(location),
      current: state.current == location ? None() : null,
    ));

    await entry.cubit?.delete();
  }
}
