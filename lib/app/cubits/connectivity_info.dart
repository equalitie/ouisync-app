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

  Future<void> update() async {
    final listenerAddrs = await _session.listenerAddrs.then(
        (addrs) => addrs.map(PeerAddr.parse).whereType<PeerAddr>().toList());

    if (isClosed) {
      return;
    }

    emitUnlessClosed(state.copyWith(listenerAddrs: listenerAddrs));

    final localIPv4 = await _networkInfo.getWifiIP();

    if (isClosed) {
      return;
    }

    if (localIPv4 != null) {
      final port = listenerAddrs
              .where((addr) => addr.isIPv4)
              .map((addr) => addr.port)
              .firstOrNull ??
          0;
      emitUnlessClosed(state.copyWith(localAddressV4: "$localIPv4:$port"));
    } else {
      emitUnlessClosed(state.copyWith(localAddressV4: ""));
    }

    final localIPv6 = await _networkInfo.getWifiIPv6();

    if (isClosed) {
      return;
    }

    if (localIPv6 != null) {
      final port = listenerAddrs
              .where((addr) => addr.isIPv6)
              .map((addr) => addr.port)
              .firstOrNull ??
          0;
      emitUnlessClosed(state.copyWith(localAddressV6: "[$localIPv6]:$port"));
    } else {
      emitUnlessClosed(state.copyWith(localAddressV6: ""));
    }

    final externalAddressV4 = await _session.externalAddressV4 ?? "";

    if (isClosed) {
      return;
    }

    emitUnlessClosed(state.copyWith(externalAddressV4: externalAddressV4));

    final externalAddressV6 = await _session.externalAddressV6 ?? "";

    if (isClosed) {
      return;
    }

    emitUnlessClosed(state.copyWith(externalAddressV6: externalAddressV6));
  }
}
