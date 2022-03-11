import 'package:collection/collection.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../models/named_repo.dart';
import '../models/models.dart';

class RepositoriesService {
  static final RepositoriesService _instance = RepositoriesService._internal();

  RepositoriesService._internal();
  factory RepositoriesService() => _instance;

  static final Map<String, Repository> _repos = Map();
  
  String? _currentRepoName;

  NamedRepo? get current {
    if (_currentRepoName == null) {
      return null;
    } else {
      return getNamed(_currentRepoName!);
    }
  }

  Iterable<NamedRepo> get repos
    => _repos.entries.map((entry) => NamedRepo(entry.key, entry.value));

  setCurrent(String name) {
    _updateCurrentRepository(name, _repos[name]);
  }

  bool get hasCurrent => _currentRepoName != null;

  void _updateCurrentRepository(String name, Repository? repo) {
    if (repo == null) {
      print("Can't set current repository to null");
      _currentRepoName = null;
      return;
    }

    if (_subscriptionCallback == null) {
      throw Exception('There is not callback for sincronization');
    }

    _subscription?.cancel();
    _subscription = null;

    _currentRepoName = name;
    
    _subscription = repo.subscribe(() => 
      _subscriptionCallback!.call(_currentRepoName!)
    );
    print('Subscribed to notifications: ${name} (${repo.accessMode.name})');
  }

  Repository? get(String name) {
    return _repos[name];
  }

  NamedRepo? getNamed(String name) {
    final repo = _repos[name];
    if (repo == null) return null;
    return NamedRepo(name, repo);
  }

  void put(String name, Repository newRepo, { bool setCurrent = false }) {
    Repository? oldRepo = _repos.remove(name);

    if (oldRepo != null && oldRepo != newRepo) {
      oldRepo.close();
    }

    _repos[name] = newRepo;

    if (setCurrent && name != _currentRepoName) {
      _updateCurrentRepository(name, newRepo);
    }
  }

  void remove(String name) {
    if (_currentRepoName == name) {
      print('Canceling subscription to $name');
      _subscription?.cancel();
      _subscription = null;

      print('Cleaning current selection for repository $name');
      _currentRepoName = null;
    }

    final repo = _repos.remove(name);

    if (repo != null) {
      print('Closing repository $name');
      repo.close();
    }
  }

  void close() {
    // Make sure this function is idempotent, i.e. that calling it more than once
    // one after another won't change it's meaning nor it will crash.
    _currentRepoName = null;

    _subscription?.cancel();
    _subscription = null;

    for (var repo in _repos.values) {
      repo.close();
    }

    _repos.clear();
  }

  Subscription? _subscription;
  Subscription? get subscription => _subscription;

  void Function(String)? _subscriptionCallback;
  setSubscriptionCallback(void Function(String) callback) => {
    _subscriptionCallback = callback
  };
}
