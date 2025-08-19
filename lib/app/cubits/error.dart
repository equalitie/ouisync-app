import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync/ouisync.dart' as native;
import 'package:loggy/loggy.dart' show Loggy;
import 'package:flutter/foundation.dart' show FlutterError, PlatformDispatcher;
import 'utils.dart' show CubitActions;
import '../utils/log.dart' show AppLogger;

// Watch if an error happened in different parts of the app and the ouisync library.
// Only captures errors that can't be gracefuly handled, the cubit indicates to
// the user that the log should be captured.
class ErrorCubit extends Cubit<ErrorCubitState> with CubitActions, AppLogger {
  ErrorCubit(native.Session session) : super(ErrorCubitState(false)) {
    // NOTE: Depending on where a panic happens inside the Rust code, we either
    // can detect it through the state monitor, or the server/service closes
    // the connection and we disconnect. The latter is caught through the
    // `onError` handlers set up below.
    unawaited(
      _RustPanicDetectionRunner(this, loggy, session.rootStateMonitor).init(),
    );

    // These are printed in utils/log.dart. Here we just mark the state with
    // error for the error badge indicator to light up.
    final defaultFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      _emitError();

      if (defaultFlutterOnError != null) {
        defaultFlutterOnError(details);
      }
    };

    final defaultPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (exception, stack) {
      _emitError();

      if (defaultPlatformOnError != null) {
        return defaultPlatformOnError(exception, stack);
      } else {
        // We're not writing the log, returning `false` means someone else will.
        return false;
      }
    };
  }

  void _emitError() {
    emitUnlessClosed(ErrorCubitState(true));
  }
}

class ErrorCubitState extends Equatable {
  final bool errorHappened;

  ErrorCubitState(this.errorHappened);

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

  Future<void> init() async {
    try {
      await _load();

      await for (final _ in _serviceStateMonitor.changes) {
        await _load();
      }
    } catch (e) {
      _loggy.error("Rust panic detection: $e");
      _errorCubit._emitError();
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
