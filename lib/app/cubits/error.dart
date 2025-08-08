import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' as native;
import 'package:loggy/loggy.dart' show Loggy;
import 'package:flutter/foundation.dart' show FlutterError, PlatformDispatcher;
import 'utils.dart' show CubitActions;
import '../utils/log.dart' show AppLogger;

// Watch if an error happened in different parts of the app and the ouisync library.
class ErrorCubit extends Cubit<ErrorCubitState> with CubitActions, AppLogger {
  ErrorCubit({required native.StateMonitor nativeOuisyncRootStateMonitor})
    : super(ErrorCubitState(false)) {
    unawaited(
      _RustPanicDetectionRunner(
        this,
        loggy,
        nativeOuisyncRootStateMonitor,
      ).init(),
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

class ErrorCubitState {
  bool errorHappened = false;

  ErrorCubitState(this.errorHappened);
}

class _RustPanicDetectionRunner {
  ErrorCubit _errorCubit;
  Loggy _loggy;
  native.StateMonitor _serviceStateMonitor;

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
