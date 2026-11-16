part of 'session_handle.dart';

/// Methods that forward to [Session], plus the repository methods that also maintain the
/// repository cache owned by [SessionHandle].
mixin SessionProxy {
  ValueNotifier<int> get started;

  /// Supplied by the class that uses this mixin.
  Future<Session> get _session;
  Future<Server?> get _server;

  /// Cache of opened repositories, owned by the class. Cleared when the session is replaced.
  Map<String, Repository>? get _reposCached;

  /// The cache of the current session, resolving (and so starting) the session first.
  Future<Map<String, Repository>> get _repos;

  /// Setup notification indicating the server is running. Currently this has effect only on
  /// Android (where the server is backed by [foreground service]
  /// (https://developer.android.com/develop/background-work/services/fgs)).
  Future<void> notify({
    String? channelName,
    String? contentTitle,
    String? contentText,
  }) async {
    await (await _server)?.notify(
      channelName: channelName,
      contentTitle: contentTitle,
      contentText: contentText,
    );
  }

  // Identity and keys

  Future<PublicRuntimeId> getRuntimeId() async {
    final s = await _session;
    return s.getRuntimeId();
  }

  Future<SecretKey> deriveSecretKey(
    Password password,
    PasswordSalt salt,
  ) async {
    final session = await _session;
    return session.deriveSecretKey(password, salt);
  }

  Future<String> getShareTokenInfoHash(ShareToken token) async {
    final session = await _session;
    return session.getShareTokenInfoHash(token);
  }

  Future<ShareToken> validateShareToken(String token) async {
    final session = await _session;
    return session.validateShareToken(token);
  }

  Future<AccessMode> getShareTokenAccessMode(ShareToken token) async {
    final session = await _session;
    return session.getShareTokenAccessMode(token);
  }

  // Share tokens

  Future<String> getShareTokenSuggestedName(ShareToken token) async =>
      (await _session).getShareTokenSuggestedName(token);

  // Network events and state monitor. The returned stream/monitor is bound to the current
  // session and stops working once the session is replaced (see `started`).

  Future<Stream<NetworkEvent>> networkEvents() async =>
      (await _session).networkEvents;

  Future<StateMonitor> getRootStateMonitor() async =>
      (await _session).rootStateMonitor;

  // Network

  Future<NatBehavior?> getNatBehavior() async =>
      (await _session).getNatBehavior();

  Future<List<PeerInfo>> getPeers() async => (await _session).getPeers();

  Future<Stats> getNetworkStats() async => (await _session).getNetworkStats();

  Future<String?> getExternalAddrV4() async =>
      (await _session).getExternalAddrV4();

  Future<String?> getExternalAddrV6() async =>
      (await _session).getExternalAddrV6();

  Future<List<String>> getLocalListenerAddrs() async =>
      (await _session).getLocalListenerAddrs();

  Future<List<String>> getRemoteListenerAddrs(String host) async =>
      (await _session).getRemoteListenerAddrs(host);

  Future<bool> mirrorExists(ShareToken token, String host) async =>
      (await _session).mirrorExists(token, host);

  Future<void> bindNetwork(List<String> addrs) async =>
      (await _session).bindNetwork(addrs);

  Future<bool> isLocalDiscoveryEnabled() async =>
      (await _session).isLocalDiscoveryEnabled();

  Future<void> setLocalDiscoveryEnabled(bool enabled) async =>
      (await _session).setLocalDiscoveryEnabled(enabled);

  Future<bool> isPortForwardingEnabled() async =>
      (await _session).isPortForwardingEnabled();

  Future<void> setPortForwardingEnabled(bool enabled) async =>
      (await _session).setPortForwardingEnabled(enabled);

  // User provided peers

  Future<List<String>> getUserProvidedPeers() async =>
      (await _session).getUserProvidedPeers();

  Future<void> addUserProvidedPeers(List<String> addrs) async =>
      (await _session).addUserProvidedPeers(addrs);

  Future<void> removeUserProvidedPeers(List<String> addrs) async =>
      (await _session).removeUserProvidedPeers(addrs);

  // Protocol version

  Future<int> getCurrentProtocolVersion() async =>
      (await _session).getCurrentProtocolVersion();

  Future<int> getHighestSeenProtocolVersion() async =>
      (await _session).getHighestSeenProtocolVersion();

  // Mount and store dirs

  Future<String?> getMountRoot() async => (await _session).getMountRoot();

  Future<void> setMountRoot(String? path) async =>
      (await _session).setMountRoot(path);

  Future<List<String>> getStoreDirs() async => (await _session).getStoreDirs();

  Future<void> setStoreDirs(List<String> paths) async =>
      (await _session).setStoreDirs(paths);

  Future<void> insertStoreDirs(List<String> paths) async =>
      (await _session).insertStoreDirs(paths);

  // Repositories. These keep `_reposCached` in sync with the session.

  Future<Repository> openRepository({
    required String path,
    LocalSecret? localSecret,
  }) async {
    final s = await _session;
    final repo = await s.openRepository(path: path, localSecret: localSecret);
    _reposCached?[path] = repo;
    return repo;
  }

  Future<Map<String, Repository>> listRepositories() async {
    // Return a snapshot: callers iterate across awaits while open/create insert into `_repos`.
    return Map.of(await _repos);
  }

  Future<Repository> getRepository({
    required String path,
    LocalSecret? localSecret,
  }) async {
    final repo = (await _repos)[path];
    return repo ?? await openRepository(path: path, localSecret: localSecret);
  }

  /// Re-keys the cached handle of a repository that has been moved, so lookups by the new path hit
  /// the cache and the old path no longer resolves to it. Synchronous on purpose: callers pair it
  /// with updating their own idea of the path, with no await in between.
  void repositoryMoved(String oldPath, String? newPath) {
    final repo = _reposCached?.remove(oldPath);
    if (repo != null && newPath != null) {
      _reposCached?[newPath] = repo;
    }
  }

  Future<Repository> createRepository({
    required String path,
    SetLocalSecret? readSecret,
    SetLocalSecret? writeSecret,
    ShareToken? token,
    bool syncEnabled = false,
    bool dhtEnabled = false,
    bool pexEnabled = false,
  }) async {
    final session = await _session;
    final repo = await session.createRepository(
      path: path,
      readSecret: readSecret,
      writeSecret: writeSecret,
      token: token,
      syncEnabled: syncEnabled,
      dhtEnabled: dhtEnabled,
      pexEnabled: pexEnabled,
    );
    _reposCached?[path] = repo;
    return repo;
  }
}
