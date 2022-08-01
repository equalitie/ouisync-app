import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'dart:async';

import '../models/folder_state.dart';
import '../models/repo_state.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../cubits/cubits.dart' as cubits;

class MainState with OuiSyncAppLogger {
  final Map<String, RepoState> _repos = Map();

  bool isLoading = false;

  String? _currentRepoName;

  final _currentRepoCubit = cubits.Value<RepoState?>(null);

  cubits.Value<RepoState?> get currentRepoCubit => _currentRepoCubit;

  MainState() {
    _currentRepoCubit.emit(null);
  }

  String? get currentRepoName => _currentRepoName;

  Iterable<String> repositoryNames() => _repos.keys;

  RepoState? get currentRepo {
    if (_currentRepoName == null) {
      return null;
    } else {
      return _repos[_currentRepoName!];
    }
  }

  FolderState? get currentFolder {
    return currentRepo?.currentFolder;
  }

  Iterable<RepoState> get repos => _repos.entries.map((entry) => entry.value);

  Future<void> setCurrent(RepoState? repo) async {
    if (repo == null) {
      _updateCurrentRepository(null);
    } else {
      await put(repo, setCurrent: true);
    }
  }

  void _updateCurrentRepository(RepoState? repo) {
    NativeChannels.setRepository(repo?.handle);

    if (repo == null) {
      loggy.app("Can't set current repository to null");
      _currentRepoName = null;
      _currentRepoCubit.emit(null);
      return;
    }

    if (_subscriptionCallback == null) {
      throw Exception('There is not callback for synchronization');
    }

    _subscription?.cancel();
    _subscription = null;

    _currentRepoName = repo.name;
    _currentRepoCubit.emit(repo);

    _subscription = repo.handle.subscribe(() => _subscriptionCallback!.call(repo));

    loggy.app('Subscribed to notifications: ${repo.name} (${repo.accessMode.name})');
  }

  RepoState? get(String name) {
    return _repos[name];
  }

  Future<void> put(RepoState newRepo, { bool setCurrent = false }) async {
    RepoState? oldRepo = _repos.remove(newRepo.name);

    if (oldRepo != null && oldRepo != newRepo) {
      await oldRepo.close();
    }

    _repos[newRepo.name] = newRepo;

    if (setCurrent && newRepo.name != _currentRepoName) {
      _updateCurrentRepository(newRepo);
    }
  }

  Future<void> remove(String name) async {
    if (_currentRepoName == name) {
      loggy.app('Canceling subscription to $name');
      _subscription?.cancel();
      _subscription = null;

      loggy.app('Cleaning current selection for repository $name');
      _currentRepoName = null;
    }
    if (_repos.containsKey(name)) {
      loggy.app('Closing repository $name');
      await _repos[name]?.close();

      loggy.app('Removing repository $name from the service');
      _repos.remove(name);
    }
  }

  Future<void> close() async {
    // Make sure this function is idempotent, i.e. that calling it more than once
    // one after another won't change it's meaning nor it will crash.
    _currentRepoName = null;
    _currentRepoCubit.emit(null);

    _subscription?.cancel();
    _subscription = null;

    for (var repo in _repos.values) {
      await repo.close();
    }

    _repos.clear();
  }

  Subscription? _subscription;
  Subscription? get subscription => _subscription;

  void Function(RepoState)? _subscriptionCallback;

  setSubscriptionCallback(void Function(RepoState) callback) => {
    _subscriptionCallback = callback
  };
}
