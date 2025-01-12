import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/utils.dart' show AppLogger;
import 'cubits.dart' show CubitActions;

class ConnectivityInfoState extends Equatable {
  final String tcpListenerV4;
  final String tcpListenerV6;
  final String quicListenerV4;
  final String quicListenerV6;

  final String localAddressV4;
  final String localAddressV6;
  final String externalAddressV4;
  final String externalAddressV6;

  ConnectivityInfoState({
    this.tcpListenerV4 = "",
    this.tcpListenerV6 = "",
    this.quicListenerV4 = "",
    this.quicListenerV6 = "",
    this.localAddressV4 = "",
    this.localAddressV6 = "",
    this.externalAddressV4 = "",
    this.externalAddressV6 = "",
  });

  ConnectivityInfoState copyWith({
    String? tcpListenerV4,
    String? tcpListenerV6,
    String? quicListenerV4,
    String? quicListenerV6,
    String? localAddressV4,
    String? localAddressV6,
    String? externalAddressV4,
    String? externalAddressV6,
  }) =>
      ConnectivityInfoState(
        tcpListenerV4: tcpListenerV4 ?? this.tcpListenerV4,
        tcpListenerV6: tcpListenerV4 ?? this.tcpListenerV6,
        quicListenerV4: quicListenerV4 ?? this.quicListenerV4,
        quicListenerV6: quicListenerV6 ?? this.quicListenerV6,
        localAddressV4: localAddressV4 ?? this.localAddressV4,
        localAddressV6: localAddressV6 ?? this.localAddressV6,
        externalAddressV4: externalAddressV4 ?? this.externalAddressV4,
        externalAddressV6: externalAddressV6 ?? this.externalAddressV6,
      );

  @override
  List<Object?> get props => [
        tcpListenerV4,
        tcpListenerV6,
        quicListenerV4,
        quicListenerV6,
        localAddressV4,
        localAddressV6,
        externalAddressV4,
        externalAddressV6,
      ];

  @override
  String toString() => "ConnectivityInfoState("
      "tcpListenerV4: $tcpListenerV4, "
      "tcpListenerV6: $tcpListenerV6, "
      "quicListenerV4: $quicListenerV4, "
      "quicListenerV6: $quicListenerV6, "
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
      _session.externalAddressV4.then((externalAddressV4) =>
        emitUnlessClosed(state.copyWith(externalAddressV4: externalAddressV4 ?? ""))),
      _session.externalAddressV6.then((externalAddressV6) =>
        emitUnlessClosed(state.copyWith(externalAddressV6: externalAddressV6 ?? "")))
    ];

    // ask the library for bound sockets; we have to block here because we
    // have a data dependency as fallbacks for local addresses when we're
    // unable to obtain them via the operating system interface
    // TODO: change the UI to be more agnostic to what we expose (e.g. support
    // multiple ports per proto, missing protos, etc); imo, the library is
    // doing the right thing here by only exposing a list of strings
    String? tcpListenerV4;
    String? tcpListenerV6;
    String? quicListenerV4;
    String? quicListenerV6;
    for (final listener in await _session.listenerAddrs) {
      if (listener.startsWith("tcp/")) {
        if (listener.contains(".")) {
          tcpListenerV4 = listener.substring(4);
        } else {
          tcpListenerV6 = listener.substring(4);
        }
      } else if(listener.startsWith("quic/")) {
        if (listener.contains(".")) {
          quicListenerV4 = listener.substring(5);
        } else {
          quicListenerV6 = listener.substring(5);
        }
      }
    }
    emitUnlessClosed(state.copyWith(
      tcpListenerV4: tcpListenerV4 ?? "",
      tcpListenerV6: tcpListenerV6 ?? "",
      quicListenerV4: quicListenerV4 ?? "",
      quicListenerV6: quicListenerV6 ?? ""
    ));

    // we can now get wifi address since we _probably_ have fallbacks
    futures.add(_networkInfo.getWifiIP().then((localIPv4) {
      if (localIPv4 != null) {
        final port = _extractPort(quicListenerV4 ?? tcpListenerV4 ?? "");
        emitUnlessClosed(state.copyWith(localAddressV4: "$localIPv4:$port"));
      } else {
        emitUnlessClosed(state.copyWith(localAddressV4: ""));
      }
    }));
    futures.add(_networkInfo.getWifiIPv6().then((localIPv6) {
      if (localIPv6 != null) {
        final port = _extractPort(quicListenerV6 ?? tcpListenerV6 ?? "");
        emitUnlessClosed(state.copyWith(localAddressV6: "[$localIPv6]:$port"));
      } else {
        emitUnlessClosed(state.copyWith(localAddressV6: ""));
      }
    }));

    // wait for everything to complete in any order
    await Future.wait(futures);
  }
}

int _extractPort(String addr) {
  final i = addr.lastIndexOf(':');

  if (i > 0) {
    return int.tryParse(addr.substring(i + 1)) ?? 0;
  } else {
    return 0;
  }
}
