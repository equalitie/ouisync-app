import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync/ouisync.dart' as native;
import 'package:loggy/loggy.dart' show Loggy;
import 'package:flutter/foundation.dart' show FlutterError, PlatformDispatcher;
import 'utils.dart' show CubitActions;
import '../utils/log.dart' show AppLogger;

// Keep only the most recent errors so a chatty stretch (e.g. several subscriptions erroring
// around the same reconnect) can't make this grow without bound.
const _maxRecordedErrors = 20;

// Watch if an error happened in different parts of the app and the ouisync library.
// Only captures errors that can't be gracefuly handled, the cubit indicates to
// the user that the log should be captured.
class ErrorCubit extends Cubit<ErrorCubitState> with CubitActions, AppLogger {
  ErrorCubit(native.Session session) : super(ErrorCubitState(const [])) {
    // NOTE: Depending on where a panic happens inside the Rust code, we either
    // can detect it through the state monitor, or the server/service closes
    // the connection and we disconnect. The latter is caught through the
    // `onError` handlers set up below.
    unawaited(
      _RustPanicDetectionRunner(this, loggy, session.rootStateMonitor).init(),
    );

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
      _emitError('Unhandled platform exception: $exception', stack);

      if (defaultPlatformOnError != null) {
        return defaultPlatformOnError(exception, stack);
      } else {
        // We're not writing the log, returning `false` means someone else will.
        return false;
      }
    };
  }

  void _emitError(String message, [StackTrace? stack]) {
    final record = ErrorRecord(
      timestamp: DateTime.now(),
      message: message,
      stack: stack,
    );
    final messages = [...state.errors, record];

    if (messages.length > _maxRecordedErrors) {
      messages.removeRange(0, messages.length - _maxRecordedErrors);
    }

    emitUnlessClosed(ErrorCubitState(messages));
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
  final List<ErrorRecord> errors;

  const ErrorCubitState(this.errors);

  bool get errorHappened => errors.isNotEmpty;

  @override
  List<Object> get props => [errors];
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

  Future<void> init() async {
    try {
      await _load();

      await for (final _ in _serviceStateMonitor.changes) {
        await _load();
      }
    } catch (e) {
      _loggy.error("Rust panic detection: $e");
      _errorCubit._emitError("Rust panic detection: $e");
    }
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
