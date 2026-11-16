import 'dart:async' show Completer;
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:ouisync/ouisync.dart';

import 'constants.dart' show Constants;
import 'dirs.dart';
import 'log.dart' as log;

part 'session_handle_proxy.dart';

// How long a session probe may take before we consider the service dead.
const _probeTimeout = Duration(milliseconds: 50);

// Upper bound on closing an old session/server. A dead connection can make `close()` hang.
const _shutdownTimeout = Duration(milliseconds: 100);

/// Owns the Ouisync server and the session connected to it, and recreates both when they stop
/// working.
///
/// The server runs inside the app process on iOS/macOS, so it is gone once the app has been in
/// the background. When the app resumes, the session is probed and, if it no longer answers, the
/// server and session are recreated.
///
/// Consumers hold this handle instead of a [Session] and call [session] each time they need one.
/// Anything bound to a previous session (streams, repository handles, mounts, ...) stops working
/// once the session is replaced. The handle does not yet notify consumers when that happens. The
/// UI itself is not rebuilt, so widget state survives.
class SessionHandle with SessionProxy {
  final Dirs? _dirs;

  /// Counts how many times a session has been started. It is incremented every time a session is
  /// created, including the replacement created after a reset, so a listener is notified exactly
  /// when a new session is available and should re-initialize against it (resolve it through
  /// [_session]). The value itself carries no meaning beyond that. Adding a listener does not call
  /// it.

  @override
  final started = ValueNotifier<int>(0);
  final _logger = log.named('Session');

  Completer<void>? backgroundHold;

  @override
  Future<Map<String, Repository>> get _repos async {
    // Resolving the session starts it if needed, which also refreshes `_repos`.
    await _session;
    return _reposCached ?? SplayTreeMap();
  }

  Server? _serverForTesting;
  Session? _sessionForTesting;

  Server? _serverCached;
  Session? _sessionCached;

  @override
  Map<String, Repository>? _reposCached;

  Future<Session>? _starting;
  Future<void>? _probing;

  bool _closed = false;

  SessionHandle._(Dirs dirs) : _dirs = dirs;

  /// Wraps an already running server and session, for tests.
  @visibleForTesting
  SessionHandle.wrap(Session session, {Server? server})
    : _dirs = null,
      _serverForTesting = server,
      _sessionForTesting = session;

  /// Creates the handle without starting anything. The server and session are started lazily on
  /// the first call to [session], and any startup error is thrown from that call.
  static Future<SessionHandle> create(
    Dirs dirs,
    // PlatformWindowManager windowManager,
  ) async {
    final handle = SessionHandle._(dirs);

    // windowManager.onClose(() => handle.close());

    return handle;
  }

  /// The current session. It is replaced after a reset (see [probeThenResetIfNeeded]), so don't
  /// keep the returned value around; keep the handle instead.
  @override
  Future<Session> get _session async => await _getServerAndSession();

  @override
  Future<Server?> get _server async {
    await _session;
    return _serverCached;
  }

  Future<void> close() async {
    if (_closed) {
      return;
    }

    _closed = true;

    // Let an in-flight probe or start finish first, so the session it leaves behind is the one
    // closed here. Its errors are already logged where they happened.
    try {
      await _probing;
      await _starting;
    } catch (_) {
      // The restart's own failure is already logged; close only needs it to have finished.
    }
    await _closeServerAndSession();
    started.dispose();
  }

  Future<void> probeThenResetIfNeeded() {
    return _probing ??= _probeThenResetIfNeeded().whenComplete(
      () => _probing = null,
    );
  }

  // Probe and reset are one operation, so `_probing` stays set until the reset has finished.
  Future<void> _probeThenResetIfNeeded() async {
    // await _server?.stop();
    if (Platform.isIOS) {
      await backgroundHold?.future;
      backgroundHold = null;
    }

    if (await _probeSessionIfResponsive()) {
      return;
    }
    await _closeServerAndSession();
  }

  Future<bool> _probeSessionIfResponsive() async {
    // A restart is already in progress, so the session is about to be replaced anyway.
    if (_closed) {
      return true;
    }
    await _starting;

    try {
      await _sessionCached?.getRuntimeId().timeout(_probeTimeout);
    } catch (e) {
      _logger.warning('ouisync service not responding after resume: $e');
      return false;
    }
    return true;
  }

  Future<void> _closeServerAndSession() async {
    try {
      await _sessionCached?.close().timeout(_shutdownTimeout);
    } catch (e) {
      _logger.warning('failed to close session: $e');
    } finally {
      _sessionCached = null;
      _reposCached = null;
    }

    try {
      await _serverCached?.stop().timeout(_shutdownTimeout);
    } catch (e) {
      _logger.warning('failed to stop server: $e');
    } finally {
      _serverCached = null;
    }
  }

  Future<Session> _getServerAndSession() async {
    await _probing;

    if (_closed) {
      throw StateError("Session has been closed");
    }

    _sessionCached ??= _sessionForTesting;
    if (_sessionCached case final session?) {
      return session;
    }

    _serverCached ??= _serverForTesting;
    return _starting ??= _startServerAndSession().whenComplete(
      () => _starting = null,
    );
  }

  Future<Session> _startServerAndSession() async {
    if (_sessionCached case final session?) {
      return session;
    }

    if (null == _dirs) {
      throw StateError('dirs is not provided to initialize a server/session');
    }
    if (null == _serverCached) {
      final server = Server.create(configPath: _dirs.config);
      await server.initLog();
      _serverCached = server;

      try {
        await server.start();
      } catch (e, st) {
        _logger.error('failed to start server:', e, st);
        await _closeServerAndSession();
        rethrow;
      }
    }

    final Session session;
    try {
      session = await Session.create(configPath: _dirs.config);
      await session.initNetwork(
        NetworkDefaults(
          bind: Constants.defaultBindAddrs,
          portForwardingEnabled: true,
          localDiscoveryEnabled: true,
        ),
      );

      _sessionCached = session;
      _reposCached = await session.listRepositories();

      started.value += 1;
    } catch (e, st) {
      _logger.error('failed to initialize session:', e, st);
      await _closeServerAndSession();
      rethrow;
    }
    return session;
  }
}
