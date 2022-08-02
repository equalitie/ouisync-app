part of 'cubit.dart';

class ReposState with OuiSyncAppLogger {
  final Map<String, RepoCubit> _repos = Map();

  bool isLoading = false;

  String? _currentRepoName;

  final _currentRepoCubit = Value<RepoCubit?>(null);

  Value<RepoCubit?> get currentRepoCubit => _currentRepoCubit;

  ReposState() {
    _currentRepoCubit.emit(null);
  }

  String? get currentRepoName => _currentRepoName;

  Iterable<String> repositoryNames() => _repos.keys;

  RepoState? get currentRepo {
    if (_currentRepoName == null) {
      return null;
    } else {
      return _repos[_currentRepoName!]?.state;
    }
  }

  FolderState? get currentFolder {
    return currentRepo?.currentFolder;
  }

  Iterable<RepoState> get repos => _repos.entries.map((entry) => entry.value.state);

  Future<void> setCurrent(RepoCubit? repo) async {
    if (repo == null) {
      _updateCurrentRepository(null);
    } else {
      await put(repo, setCurrent: true);
    }
  }

  void _updateCurrentRepository(RepoCubit? repo) {
    oui.NativeChannels.setRepository(repo?.state.handle);

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

    _currentRepoName = repo.state.name;
    _currentRepoCubit.emit(repo);

    _subscription = repo.state.handle.subscribe(() => _subscriptionCallback!.call(repo.state));

    loggy.app('Subscribed to notifications: ${repo.state.name} (${repo.state.accessMode.name})');
  }

  RepoCubit? get(String name) {
    return _repos[name];
  }

  Future<void> put(RepoCubit newRepo, { bool setCurrent = false }) async {
    RepoCubit? oldRepo = _repos.remove(newRepo.state.name);

    if (oldRepo != null && oldRepo != newRepo) {
      await oldRepo.state.close();
    }

    _repos[newRepo.state.name] = newRepo;

    if (setCurrent && newRepo.state.name != _currentRepoName) {
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
      await _repos[name]?.state.close();

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
      await repo.state.close();
    }

    _repos.clear();
  }

  oui.Subscription? _subscription;
  oui.Subscription? get subscription => _subscription;

  void Function(RepoState)? _subscriptionCallback;

  setSubscriptionCallback(void Function(RepoState) callback) => {
    _subscriptionCallback = callback
  };
}
