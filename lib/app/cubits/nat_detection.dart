import 'dart:async';
import 'package:ouisync/ouisync.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/log.dart';

class NatDetection extends Cubit<NatBehavior> with AppLogger {
  final Session session;
  StreamSubscription<ConnectivityResult>? _subscription;

  NatDetection(this.session) : super(NatBehavior.pending) {
    final connectivity = Connectivity();

    // TODO: throttle this to at most 1 per minute or so.
    _subscription =
        connectivity.onConnectivityChanged.listen((result) => _detect(result));

    unawaited(
      connectivity.checkConnectivity().then((result) => _detect(result)),
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
      emit(NatBehavior.offline);
      return;
    }

    emit(NatBehavior.pending);
    emit(NatBehavior.parse(await session.natBehavior));
  }
}

enum NatBehavior {
  pending,
  offline,
  endpointIndependent,
  addressDependent,
  addressAndPortDependent,
  unknown,
  ;

  static NatBehavior parse(String? input) => switch (input) {
        "endpoint independent" => endpointIndependent,
        "address dependent" => addressDependent,
        "address and port dependent" => addressAndPortDependent,
        _ => unknown,
      };
}
