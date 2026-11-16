import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';

import 'session_handle.dart' show SessionHandle;

/// Calls [SessionHandle.probeThenResetIfNeeded] when the app comes back to the foreground after
/// being paused or hidden.
///
/// Attach it with [attach] and detach it with [detach]; it does nothing while detached.
class SessionHandleObserver with WidgetsBindingObserver {
  final SessionHandle _handle;

  SessionHandleObserver(this._handle);

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (Platform.isIOS) {
          _handle.backgroundHold ??= Completer();
          unawaited(_handle.probeThenResetIfNeeded());
        }
      case AppLifecycleState.resumed:
        _handle.backgroundHold?.complete();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
    }
  }
}
