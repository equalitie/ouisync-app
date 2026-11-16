import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' as o;

import '../utils/log.dart';
import '../utils/session_handle.dart' show SessionProxy;
import 'utils.dart';

class NatDetection extends Cubit<NatBehavior> with CubitActions, AppLogger {
  final SessionProxy _session;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NatDetection(SessionProxy session)
    : _session = session,
      super(NatBehavior.pending) {
    _session.started.addListener(_onSessionStarted);
    final connectivity = Connectivity();

    // TODO: throttle this to at most 1 per minute or so.
    _subscription = connectivity.onConnectivityChanged.listen(
      (result) => _detect(result.last),
    );
    _onSessionStarted();
  }

  void _onSessionStarted() {
    if (_session.started.value == 0) {
      return;
    }
    unawaited(_detectAgain());
  }

  Future<void> _detectAgain() async {
    final result = await Connectivity().checkConnectivity();
    _detect(result.last);
  }

  @override
  Future<void> close() async {
    _session.started.removeListener(_onSessionStarted);
    await _subscription?.cancel();
    _subscription = null;

    await super.close();
  }

  void _detect(ConnectivityResult result) async {
    if (result == ConnectivityResult.none ||
        result == ConnectivityResult.bluetooth) {
      emitUnlessClosed(NatBehavior.offline);
      return;
    }

    emitUnlessClosed(NatBehavior.pending);
    final nat = switch (await _session.getNatBehavior()) {
      o.NatBehavior.endpointIndependent => NatBehavior.endpointIndependent,
      o.NatBehavior.addressDependent => NatBehavior.addressDependent,
      o.NatBehavior.addressAndPortDependent =>
        NatBehavior.addressAndPortDependent,
      null => NatBehavior.unknown,
    };

    emitUnlessClosed(nat);
  }
}

enum NatBehavior {
  pending,
  offline,
  endpointIndependent,
  addressDependent,
  addressAndPortDependent,
  unknown,
}
