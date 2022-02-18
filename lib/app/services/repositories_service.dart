import 'package:collection/collection.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../models/models.dart';

class RepositoriesService {
  static final RepositoriesService _instance = RepositoriesService._internal();

  RepositoriesService._internal();
  factory RepositoriesService() => _instance;

  static final List<PersistedRepository> _repositories = <PersistedRepository>[];
  List<PersistedRepository> get repositories => _repositories;
  
  String? _current;
  
  PersistedRepository? get current => _repositories
  .singleWhereOrNull((repo) => repo.name == _current);

  setCurrent(String name) => _updateCurrentRepository(
    _repositories.singleWhereOrNull((repo) => repo.name == name)
  );

  bool get hasCurrent => _current != null;

  void _updateCurrentRepository(PersistedRepository? persisted) {
    if (persisted == null) {
      print('No repository matched the name. Current repository can not be updated');
      return;
    }

    if (_subscriptionCallback == null) {
      throw Exception('There is not callback for sincronization');
    }

    _subscription?.cancel();
    print('Subscription to $_current canceled: (${_subscription?.handle})');

    _current = persisted.name;
    
    _subscription = persisted.repository.subscribe(() => _subscriptionCallback!.call(_current!));
    print('Subscribed to ${persisted.name} notifications');
  }

  PersistedRepository? get(String name) =>
    _repositories.singleWhereOrNull((element) => element.name == name);

  void put(String name, Repository repository, {bool isCurrent = false}) {
    PersistedRepository? repo = _repositories
    .singleWhereOrNull((element) => element.name == name);

    if (repo != null) {
      repo.update(name, repository);
    }

    if (repo == null) {
      repo = PersistedRepository(
        repository: repository,
        name: name
      ); 

      _repositories.add(repo);
    }

    if (isCurrent) {
      _updateCurrentRepository(repo);
    }
  }

  void remove(String name) {
    if (_current == name) {
      _current = '';
    }

    final repo = get(name);
    repo?.repository.close();
    
    _repositories.remove(repo);
  }

  Subscription? _subscription;
  Subscription? get subscription => _subscription;

  void Function(String)? _subscriptionCallback;
  setSubscriptionCallback(void Function(String) callback) => {
    _subscriptionCallback = callback
  };
}