import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/ouisync.dart' as native;
import 'package:ouisync_app/app/cubits/session.dart';
import 'package:ouisync_app/app/utils/dirs.dart';

class _FakeServer implements native.Server {
  bool stopped = false;
  bool failInitLog = false;

  @override
  Future<void> initLog() async {
    if (failInitLog) throw 'init log failed';
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async => stopped = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSession implements native.Session {
  bool closed = false;

  /// Whether the session answers liveness probes. Set to `false` before signalling a disconnect.
  bool responsive = true;

  /// Emit an error here to simulate a disconnect.
  final disconnect = StreamController<void>.broadcast();

  @override
  Future<native.PublicRuntimeId> getRuntimeId() async {
    if (!responsive) throw 'not responding';
    return native.PublicRuntimeId([]);
  }

  @override
  Future<void> close() async => closed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Connector that records connect attempts and uses [connect] to create new server/session pairs.
class _FakeConnector extends SessionConnector {
  _FakeConnector(super.dirs, this._connect);

  final Future<(native.Server, native.Session)> Function() _connect;
  int connects = 0;

  @override
  Future<(native.Server, native.Session)> startServerAndSession() {
    connects++;
    return _connect();
  }

  @override
  Future<void> stopServerAndSession(
    native.Server server,
    native.Session session,
  ) async {
    await session.close();
    await server.stop();
  }

  @override
  StreamSubscription<void> observeSession(
    native.Session session,
    void Function(Object _) onError,
  ) => (session as _FakeSession).disconnect.stream.listen(
    (_) {},
    onError: onError,
  );
}

/// Next state in which the reconnect has finished (the cubit is no longer `connecting`).
Future<SessionState> _connected(SessionCubit cubit) =>
    cubit.stream.firstWhere((state) => !state.connecting);

void main() {
  late Dirs dirs;

  setUp(() async {
    dirs = await Dirs.init();
  });

  test('replaces the server and session when disconnected', () async {
    final server1 = _FakeServer();
    final session1 = _FakeSession();
    final server2 = _FakeServer();
    final session2 = _FakeSession();

    final connector = _FakeConnector(dirs, () async => (server2, session2));
    final cubit = SessionCubit(server1, session1, connector);

    session1.responsive = false;
    final next = _connected(cubit);
    session1.disconnect.addError('lost');
    final state = await next;

    expect(state.server, same(server2));
    expect(state.session, same(session2));
    expect(state.generation, 1);
    expect(session1.closed, isTrue);
    expect(server1.stopped, isTrue);

    await cubit.close();
  });

  test('a failed reconnect keeps the previous state', () async {
    final session1 = _FakeSession();
    final attempted = Completer<void>();

    final connector = _FakeConnector(dirs, () {
      attempted.complete();
      throw 'nope';
    });
    final cubit = SessionCubit(_FakeServer(), session1, connector);

    session1.responsive = false;
    session1.disconnect.addError('lost');
    await attempted.future;

    // close() waits for the failed reconnect to finish, so the state is settled after it.
    await cubit.close();

    expect(connector.connects, 1);
    expect(cubit.state.generation, 0);
  });

  test('ignores repeated disconnect signals while reconnecting', () async {
    final session1 = _FakeSession();
    final session2 = _FakeSession();
    final connector = _FakeConnector(
      dirs,
      () async => (_FakeServer(), session2),
    );
    final cubit = SessionCubit(_FakeServer(), session1, connector);

    session1.responsive = false;
    final next = _connected(cubit);
    session1.disconnect.addError('lost');
    session1.disconnect.addError('lost');
    await next;

    expect(connector.connects, 1);
    await cubit.close();
  });

  test('later disconnects of the new session reconnect again', () async {
    final session1 = _FakeSession();
    final session2 = _FakeSession();
    final session3 = _FakeSession();
    final sessions = [session2, session3];

    final connector = _FakeConnector(
      dirs,
      () async => (_FakeServer(), sessions.removeAt(0)),
    );
    final cubit = SessionCubit(_FakeServer(), session1, connector);

    session1.responsive = false;
    var next = _connected(cubit);
    session1.disconnect.addError('lost');
    await next;

    session2.responsive = false;
    next = _connected(cubit);
    session2.disconnect.addError('lost');
    final state = await next;

    expect(state.session, same(session3));
    expect(state.generation, 2);
    await cubit.close();
  });

  test('close closes the session and stops the server', () async {
    final server = _FakeServer();
    final session = _FakeSession();
    final connector = _FakeConnector(dirs, () => throw 'unused');
    final cubit = SessionCubit(server, session, connector);

    await cubit.close();

    expect(session.closed, isTrue);
    expect(server.stopped, isTrue);
    expect(connector.connects, 0);
  });

  test('close during a reconnect closes the new session instead of '
      'leaving it running', () async {
    final session1 = _FakeSession();
    final session2 = _FakeSession();
    final server2 = _FakeServer();
    final connectStarted = Completer<void>();
    final connectResult = Completer<(native.Server, native.Session)>();

    final connector = _FakeConnector(dirs, () {
      connectStarted.complete();
      return connectResult.future;
    });
    final cubit = SessionCubit(_FakeServer(), session1, connector);

    session1.responsive = false;
    session1.disconnect.addError('lost');
    await connectStarted.future;

    // close() waits for the reconnect in progress to finish before tearing things down.
    final closing = cubit.close();
    connectResult.complete((server2, session2));
    await closing;

    expect(session2.closed, isTrue);
    expect(server2.stopped, isTrue);
  });

  test('a disconnect after close does not start a reconnect', () async {
    final session1 = _FakeSession();
    final connector = _FakeConnector(
      dirs,
      () async => (_FakeServer(), _FakeSession()),
    );
    final cubit = SessionCubit(_FakeServer(), session1, connector);

    await cubit.close();
    session1.responsive = false;
    session1.disconnect.addError('lost');
    await Future<void>.delayed(Duration.zero);

    expect(connector.connects, 0);
  });

  group('startServerAndSessionInternal', () {
    test('returns the server and session when everything succeeds', () async {
      final connector = SessionConnector(dirs);
      final server = _FakeServer();
      final session = _FakeSession();

      final (s, ss) = await connector.startServerAndSessionInternal(
        server: server,
        createSession: () async => session,
        initNetwork: (_) async {},
      );

      expect(s, same(server));
      expect(ss, same(session));
      expect(server.stopped, isFalse);
      expect(session.closed, isFalse);
    });

    test(
      'closes the session and stops the server when initNetwork fails',
      () async {
        final connector = SessionConnector(dirs);
        final server = _FakeServer();
        final session = _FakeSession();

        await expectLater(
          connector.startServerAndSessionInternal(
            server: server,
            createSession: () async => session,
            initNetwork: (_) async => throw 'network failed',
          ),
          throwsA('network failed'),
        );

        expect(session.closed, isTrue);
        expect(server.stopped, isTrue);
      },
    );

    test('stops the server when creating the session fails', () async {
      final connector = SessionConnector(dirs);
      final server = _FakeServer();

      await expectLater(
        connector.startServerAndSessionInternal(
          server: server,
          createSession: () async => throw 'create failed',
          initNetwork: (_) async {},
        ),
        throwsA('create failed'),
      );

      expect(server.stopped, isTrue);
    });

    test('stops the server when initLog fails', () async {
      final connector = SessionConnector(dirs);
      final server = _FakeServer()..failInitLog = true;
      var sessionCreated = false;

      await expectLater(
        connector.startServerAndSessionInternal(
          server: server,
          createSession: () async {
            sessionCreated = true;
            return _FakeSession();
          },
          initNetwork: (_) async {},
        ),
        throwsA('init log failed'),
      );

      expect(server.stopped, isTrue);
      expect(sessionCreated, isFalse);
    });
  });
}
