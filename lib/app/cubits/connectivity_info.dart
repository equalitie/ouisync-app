import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/peer_addr.dart';
import '../utils/utils.dart' show AppLogger;
import 'cubits.dart' show CubitActions;

class ConnectivityInfoState extends Equatable {
  final List<PeerAddr> listenerAddrs;

  final String localAddressV4;
  final String localAddressV6;
  final String externalAddressV4;
  final String externalAddressV6;

  ConnectivityInfoState({
    this.listenerAddrs = const [],
    this.localAddressV4 = "",
    this.localAddressV6 = "",
    this.externalAddressV4 = "",
    this.externalAddressV6 = "",
  });

  ConnectivityInfoState copyWith({
    List<PeerAddr>? listenerAddrs,
    String? localAddressV4,
    String? localAddressV6,
    String? externalAddressV4,
    String? externalAddressV6,
  }) =>
      ConnectivityInfoState(
        listenerAddrs: listenerAddrs ?? this.listenerAddrs,
        localAddressV4: localAddressV4 ?? this.localAddressV4,
        localAddressV6: localAddressV6 ?? this.localAddressV6,
        externalAddressV4: externalAddressV4 ?? this.externalAddressV4,
        externalAddressV6: externalAddressV6 ?? this.externalAddressV6,
      );

  @override
  List<Object?> get props => [
        listenerAddrs,
        localAddressV4,
        localAddressV6,
        externalAddressV4,
        externalAddressV6,
      ];

  @override
  String toString() => "ConnectivityInfoState("
      "listenerAddrs: $listenerAddrs, "
      "localAddressV4: $localAddressV4, "
      "localAddressV6: $localAddressV6, "
      "externalAddressV4: $externalAddressV4, "
      "externalAddressV6: $externalAddressV6)";
}

class ConnectivityInfo extends Cubit<ConnectivityInfoState>
    with AppLogger, CubitActions {
  final Session _session;
  final _networkInfo = NetworkInfo();

  ConnectivityInfo(Session session)
      : _session = session,
        super(ConnectivityInfoState());

  // refresh network settings
  Future<void> update() async {
    // because these events are idempotent, we can trigger them in any order
    // we start with getting the routable addresses (without waiting just yet)
    List<Future> futures = [
      _session.getExternalAddrV4().then((externalAddressV4) => emitUnlessClosed(
          state.copyWith(externalAddressV4: externalAddressV4 ?? ""))),
      _session.getExternalAddrV6().then((externalAddressV6) => emitUnlessClosed(
          state.copyWith(externalAddressV6: externalAddressV6 ?? "")))
    ];

    // ask the library for bound sockets; we have to block here because we
    // have a data dependency as fallbacks for local addresses when we're
    // unable to obtain them via the operating system interface
    final listenerAddrs = await _session.getLocalListenerAddrs().then(
        (addrs) => addrs.map(PeerAddr.parse).whereType<PeerAddr>().toList());

    emitUnlessClosed(state.copyWith(listenerAddrs: listenerAddrs));

    // we can now get wifi address since we _probably_ have fallbacks
    futures.add(_networkInfo.getWifiIP().then((localIPv4) {
      if (localIPv4 != null) {
        final port = listenerAddrs
                .where((addr) => addr.isIPv4)
                .map((addr) => addr.port.toString())
                .firstOrNull ??
            "";
        emitUnlessClosed(state.copyWith(localAddressV4: "$localIPv4:$port"));
      } else {
        emitUnlessClosed(state.copyWith(localAddressV4: ""));
      }
    }));
    futures.add(_networkInfo.getWifiIPv6().then((localIPv6) {
      if (localIPv6 != null) {
        final port = listenerAddrs
                .where((addr) => addr.isIPv6)
                .map((addr) => addr.port.toString())
                .firstOrNull ??
            "";
        emitUnlessClosed(state.copyWith(localAddressV6: "[$localIPv6]:$port"));
      } else {
        emitUnlessClosed(state.copyWith(localAddressV6: ""));
      }
    }));

    // then wait for everything to complete in any order
    await Future.wait(futures);
  }
}
