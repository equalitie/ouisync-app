import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/utils/constants.dart';
import 'package:ouisync_app/app/utils/dirs.dart';

import '../utils/log.dart' show AppLogger;
import 'utils.dart' show CubitActions;

class SessionState extends Equatable {
  const SessionState(
    this.server,
    this.session,
    this.generation,
    this.error,
    this.connecting,
  );

  final Server server;
  final Session session;

  /// Incremented every time the session is replaced after a reconnect. Use as a widget key to
  /// rebuild everything that depends on the session.
  final int generation;
  final Object? error;
  final bool connecting;

  @override
  List<Object?> get props => [server, session, generation, error, connecting];
}

class SessionCubit extends Cubit<SessionState> with CubitActions, AppLogger {
  SessionCubit(Server server, Session session, SessionConnector connector)
    : _sessionConnector = connector,
      // The parameters are named publicly (for tests), so they can't be private initializing formals.
      super(SessionState(server, session, 0, null, false)) {
    _sessionObservationStart(session);
  }

  static Future<SessionCubit> create(Dirs dirs) async {
    final connector = SessionConnector(dirs);
    final (server, session) = await connector.startServerAndSession();
    final cubit = SessionCubit(server, session, connector);
    return cubit;
  }

  Server get server => state.server;
  Session get session => state.session;

  final SessionConnector _sessionConnector;

  StreamSubscription<void>? _sessionObservation;

  final Duration _probeTimeout = Duration(milliseconds: 50);
  Future<void>? _reconnecting;

  void _sessionObservationStart(Session session) {
    _sessionObservation = _sessionConnector.observeSession(
      session,
      _onSessionError,
    );
  }

  Future<bool> _probeSession() async {
    try {
      await state.session.getRuntimeId().timeout(_probeTimeout);
    } catch (e) {
      loggy.warning('ouisync service not responding after resume: $e');
      return false;
    }
    return true;
  }

  Future<void> _sessionObservationStop() async {
    final observation = _sessionObservation;
    _sessionObservation = null;
    await observation?.cancel();
  }

  void _onSessionError(Object e) {
    unawaited(_reconnect());
  }

  /// Restarts the server and session on request, even if the current session still answers probes.
  Future<void> reconnect() => _reconnect(force: true);

  Future<void> _reconnect({bool force = false}) async {
    return _reconnecting ??= _reconnectTask(force: force)
        .whenComplete(() => _reconnecting = null);
  }

  Future<void> _reconnectTask({bool force = false}) async {
    if (isClosed) return;
    if (!force && await _probeSession()) return;

    loggy.warning('Session disconnected, reconnecting');
    final reconnectingState = SessionState(
      state.server,
      state.session,
      state.generation,
      state.error,
      true,
    );
    emitUnlessClosed(reconnectingState);

    // Stop watching first so closing the old session isn't mistaken for another disconnect.
    await _sessionObservationStop();
    await _sessionConnector.stopServerAndSession(state.server, state.session);

    try {
      final (server, session) = await _sessionConnector.startServerAndSession();
      _sessionObservationStart(session);
      emit(SessionState(server, session, state.generation + 1, null, false));
      loggy.info('Session reconnected');
    } catch (e) {
      emit(
        SessionState(state.server, state.session, state.generation, e, false),
      );
      loggy.error('Failed to reconnect session :', e);
    }
  }

  @override
  Future<void> close() async {
    await _reconnecting;
    await _sessionObservationStop();
    await _sessionConnector.stopServerAndSession(server, session);
    await super.close();
  }
}

class SessionConnector with AppLogger {
  SessionConnector(this._dirs);

  final Dirs _dirs;
  final Duration _shutdownTimeout = Duration(milliseconds: 100);

  Future<(Server, Session)> startServerAndSession() =>
      startServerAndSessionInternal(
        server: Server.create(configPath: _dirs.config),
        createSession: () => Session.create(configPath: _dirs.config),
        initNetwork: (session) => session.initNetwork(
          NetworkDefaults(
            bind: Constants.defaultBindAddrs,
            portForwardingEnabled: true,
            localDiscoveryEnabled: true,
          ),
        ),
      );

  Future<void> stopServerAndSession(Server server, Session session) async {
    try {
      await session.close().timeout(_shutdownTimeout);
    } catch (e) {
      loggy.warning('Failed to close the session: $e');
    }

    try {
      await server.stop().timeout(_shutdownTimeout);
    } catch (e) {
      loggy.warning('Failed to stop the server: $e');
    }
  }

  StreamSubscription<void> observeSession(
    Session session,
    void Function(Object _) onError,
  ) => session.rootStateMonitor
      .child(MonitorId.expectUnique('Service'))
      .changes
      .listen((_) {}, onError: (Object o) => onError(o));

  /// Brings up [server] and a session created by [createSession]. On failure, everything opened so
  /// far is closed again before the error is rethrown.
  @visibleForTesting
  Future<(Server, Session)> startServerAndSessionInternal({
    required Server server,
    required Future<Session> Function() createSession,
    required Future<void> Function(Session session) initNetwork,
  }) async {
    try {
      await server.initLog();
      await server.start();
    } catch (e, st) {
      loggy.error('failed to start server:', e, st);
      await _stopServerQuietly(server);
      rethrow;
    }

    Session? session;

    try {
      session = await createSession();
      await initNetwork(session);
      return (server, session);
    } catch (e, st) {
      loggy.error('failed to initialize session:', e, st);

      if (session != null) {
        await _closeSessionQuietly(session);
      }

      await _stopServerQuietly(server);
      rethrow;
    }
  }

  // Cleanup on the error path: a failure here must not hide the original error.
  Future<void> _stopServerQuietly(Server server) async {
    try {
      await server.stop().timeout(_shutdownTimeout);
    } catch (e) {
      loggy.warning('Failed to stop the server during cleanup: $e');
    }
  }

  Future<void> _closeSessionQuietly(Session session) async {
    try {
      await session.close().timeout(_shutdownTimeout);
    } catch (e) {
      loggy.warning('Failed to close the session during cleanup: $e');
    }
  }
}
