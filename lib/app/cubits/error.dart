import 'dart:async';
import 'dart:io' show Platform, SocketException;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync/ouisync.dart' as native;
import 'package:loggy/loggy.dart' show Loggy;
import 'package:flutter/foundation.dart' show FlutterError, PlatformDispatcher;

import 'utils.dart' show CubitActions;
import '../utils/log.dart' show AppLogger;
import '../utils/session_handle.dart' show SessionHandle;

// Keep only the most recent errors so a chatty stretch (e.g. several subscriptions erroring
// around the same restart) can't make this grow without bound.
const _maxRecordedErrors = 20;

// Watch if an error happened in different parts of the app and the ouisync library.
// Only captures errors that can't be gracefuly handled, the cubit indicates to
// the user that the log should be captured.
class ErrorCubit extends Cubit<ErrorCubitState> with CubitActions, AppLogger {
  final List<ErrorRecord> _errors = [];
  final SessionHandle _session;
  bool _closing = false;

  // The runner currently watching the session's state monitor, if any. At most one is alive: a
  // restart (or close) stops it before another one is created.
  _RustPanicDetectionRunner? _panicRunner;

  ErrorCubit(SessionHandle session)
    : _session = session,
      super(ErrorCubitState(false)) {
    // NOTE: Depending on where a panic happens inside the Rust code, we either
    // can detect it through the state monitor, or the server/service closes
    // the connection and we disconnect. The latter is caught through the
    // `onError` handlers set up below.

    // The state monitor belongs to the session, so the watch has to be armed again after a restart.
    _session.started.addListener(_onSessionStarted);
    _onSessionStarted();

    // These are printed in utils/log.dart. Here we just record the message for the error badge
    // indicator (and whoever wants to read it) and let the default handler also log it.
    final defaultFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      _emitError(
        'Unhandled Flutter exception: ${details.exceptionAsString()}',
        details.stack,
      );

      if (defaultFlutterOnError != null) {
        defaultFlutterOnError(details);
      }
    };

    final defaultPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (exception, stack) {
      if (_isSuspendedSocketError(exception)) {
        // Same non-error as in the panic watcher: the client's pending futures fail when iOS
        // invalidates the socket. Several can fail at once, so log each at WARN and mark the
        // exception handled so it isn't also logged as an unhandled error.
        loggy.warning('Connection lost: $exception');
        unawaited(_session.probeThenResetIfNeeded());
        return true;
      }

      _emitError('Unhandled platform exception: $exception', stack);

      if (defaultPlatformOnError != null) {
        return defaultPlatformOnError(exception, stack);
      } else {
        // We're not writing the log, returning `false` means someone else will.
        return false;
      }
    };
  }

  void _onSessionStarted() {
    if (_session.started.value == 0) {
      return;
    }
    unawaited(_startWatchForPanics());
  }

  @override
  Future<void> close() async {
    _closing = true;
    _session.started.removeListener(_onSessionStarted);
    await _stopWatchForPanics();
    await super.close();
  }

  // Recorded errors, oldest first. Read when the user opens the error list in Settings.
  List<ErrorRecord> get errors => List.unmodifiable(_errors);

  Future<void> _stopWatchForPanics() async {
    final runner = _panicRunner;
    _panicRunner = null;
    await runner?.stop();
  }

  // (Re)arms the panic watch on the current session, stopping the previous watch first so runners
  // don't pile up across restarts.
  Future<void> _startWatchForPanics() async {
    await _stopWatchForPanics();
    try {
      final runner = _RustPanicDetectionRunner(
        this,
        loggy,
        await _session.getRootStateMonitor(),
      );
      if (_closing || isClosed) {
        return;
      }
      _panicRunner = runner;
      await runner.start();
    } catch (e) {
      _reportPanicDetectionFailure(e);
    }
  }

  // iOS invalidates the loopback socket to the embedded server when the app is suspended, so the
  // watcher fails with a `SocketException` (e.g. EBADF) that is not a panic. Don't surface it as an
  // error, just let the probe restart the session if it really is dead.
  bool _isSuspendedSocketError(Object e) =>
      Platform.isIOS && e is SocketException;

  void _reportPanicDetectionFailure(Object e) {
    if (_isSuspendedSocketError(e)) {
      loggy.warning("Rust panic detection: connection lost: $e");
      unawaited(_session.probeThenResetIfNeeded());
      return;
    }

    loggy.error("Rust panic detection: $e");
    _emitError("Rust panic detection: $e");
  }

  void _emitError(String message, [StackTrace? stack]) {
    _errors.add(
      ErrorRecord(timestamp: DateTime.now(), message: message, stack: stack),
    );

    if (_errors.length > _maxRecordedErrors) {
      _errors.removeRange(0, _errors.length - _maxRecordedErrors);
    }
    emitUnlessClosed(ErrorCubitState(true));
    unawaited(_session.probeThenResetIfNeeded());
  }

  // Called once the user has seen the errors. Clears the "error happened" flag but keeps the
  // recorded errors. A new error sets the flag again.
  void markSeen() {
    if (state.errorHappened) {
      emitUnlessClosed(ErrorCubitState(false));
    }
  }
}

class ErrorRecord extends Equatable {
  final DateTime timestamp;
  final String message;
  final StackTrace? stack;

  const ErrorRecord({
    required this.timestamp,
    required this.message,
    this.stack,
  });

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('${timestamp.toUtc().toIso8601String()} $message');

    if (stack != null) {
      buffer.writeln(stack);
    }

    return buffer.toString();
  }

  @override
  List<Object?> get props => [timestamp, message, stack];
}

class ErrorCubitState extends Equatable {
  final bool errorHappened;

  const ErrorCubitState(this.errorHappened);

  @override
  List<Object> get props => [errorHappened];
}

class _RustPanicDetectionRunner {
  final ErrorCubit _errorCubit;
  final Loggy _loggy;
  final native.StateMonitor _serviceStateMonitor;

  _RustPanicDetectionRunner(
    this._errorCubit,
    this._loggy,
    native.StateMonitor rootStateMonitor,
  ) : _serviceStateMonitor = rootStateMonitor.child(
        native.MonitorId.expectUnique("Service"),
      );

  StreamSubscription<void>? _subscription;
  bool _stopped = false;

  // Starts watching. Reports at most one failure (a detected panic, or being unable to read the
  // counter) and stops watching after it: the counter is cumulative, so every later change would
  // report the same panic again.
  Future<void> start() async {
    if (_stopped) {
      return;
    }

    try {
      // Subscribe before the first load so a change landing in between isn't missed. An extra
      // load on an early event is harmless.
      //
      // TODO: The ouisync Dart bindings never complete this stream when the session closes:
      // `Client.close()` cancels its socket listener before closing the socket, so `_receiveDone`
      // (the only place that closes the pending `subscribe()` sinks) never runs. That is why this
      // runner must be stopped explicitly (see `stop`) and why `onDone` below isn't reached on
      // session close. Fix in the bindings (Layer 2): have `Client.close()` (and probably
      // `_disconnect()`) close the notification sinks and fail the pending responses, sharing the
      // cleanup with `_receiveDone`. Afterwards decide what an unexpected `onDone` (connection lost
      // while the service survives, e.g. after a listener rebind) should do here: probably
      // re-subscribe with a delay, giving up on `StateError('client closed')`.
      _subscription = _serviceStateMonitor.changes.listen(
        (_) => unawaited(_check()),
        onError: (Object e) => _fail(e),
        onDone: () =>
            _loggy.debug("Rust panic detection: state monitor stream ended"),
      );

      await _check();
    } catch (e) {
      _fail(e);
    }
  }

  // Stops watching. Safe to call more than once. Nothing is reported after this returns.
  Future<void> stop() async {
    _stopped = true;

    final subscription = _subscription;
    _subscription = null;

    await subscription?.cancel();
  }

  Future<void> _check() async {
    if (_stopped) {
      return;
    }

    try {
      await _load();
    } catch (e) {
      _fail(e);
    }
  }

  void _fail(Object e) {
    if (_stopped) {
      return;
    }

    // Stop first so concurrent in-flight checks can't report the same failure again.
    unawaited(stop());

    _errorCubit._reportPanicDetectionFailure(e);
  }

  Future<void> _load() async {
    final node = await _serviceStateMonitor.load();

    if (node == null) {
      throw "Failed to find Service node in state monitor";
    }

    final value = node.values['panic_counter'];

    if (value == null) {
      throw "Failed to find panic_counter value in Service state monitor node";
    }

    final count = int.tryParse(value);

    if (count == null) {
      throw "Failed to parse panic_counter value ($value)";
    }

    if (count > 0) {
      throw "Detected panic in rust code";
    }
  }
}
