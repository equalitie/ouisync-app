import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' as o;

import '../utils/log.dart';
import 'utils.dart';

class NatDetection extends Cubit<NatBehavior> with CubitActions, AppLogger {
  final o.Session session;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NatDetection(this.session) : super(NatBehavior.pending) {
    final connectivity = Connectivity();

    // TODO: throttle this to at most 1 per minute or so.
    _subscription = connectivity.onConnectivityChanged
        .listen((result) => _detect(result.last));

    unawaited(
      connectivity.checkConnectivity().then((result) => _detect(result.last)),
    );
  }

  @override
  Future<void> close() async {
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

    final nat = switch (await session.getNatBehavior()) {
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
