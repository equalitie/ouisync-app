import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../models/models.dart';
import '../models/repo_state.dart';
import '../models/folder_state.dart';
import '../utils/loggers/ouisync_app_logger.dart';

class MainState with OuiSyncAppLogger {
  static final Map<String, RepoState> _repos = Map();
  
  String? _currentRepoName;

  RepoState? get current {
    if (_currentRepoName == null) {
      return null;
    } else {
      return _repos[_currentRepoName!];
    }
  }

  FolderState? get currentFolder {
    return current?.currentFolder;
  }

  Iterable<RepoState> get repos => _repos.entries.map((entry) => entry.value);

  setCurrent(String name) {
    _updateCurrentRepository(_repos[name]);
  }

  void _updateCurrentRepository(RepoState? repo) {
    if (repo == null) {
      loggy.app("Can't set current repository to null");
      _currentRepoName = null;
      return;
    }

    if (_subscriptionCallback == null) {
      throw Exception('There is not callback for synchronization');
    }

    _subscription?.cancel();
    _subscription = null;

    _currentRepoName = repo.name;
    
    _subscription = repo.repo.subscribe(() => _subscriptionCallback!.call(repo));

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
