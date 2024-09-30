import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/log.dart';

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
        quicListenerV4,
        localAddressV4,
        localAddressV6,
        externalAddressV4,
        externalAddressV6,
      ];

  @override
  String toString() =>
      "ConnectivityInfoState(" +
      "tcpListenerV4: $tcpListenerV4, " +
      "tcpListenerV6: $tcpListenerV6, " +
      "quicListenerV4: $quicListenerV4, " +
      "localAddressV4: $localAddressV4, " +
      "localAddressV6: $localAddressV6, " +
      "externalAddressV4: $externalAddressV4, " +
      "externalAddressV6: $externalAddressV6)";
}

class ConnectivityInfo extends Cubit<ConnectivityInfoState> with AppLogger {
  final Session _session;
  final _networkInfo = NetworkInfo();

  ConnectivityInfo(Session session)
      : _session = session,
        super(ConnectivityInfoState());

  Future<void> update() async {
    final tcpListenerV4 = await _session.tcpListenerLocalAddressV4;
    final tcpListenerV6 = await _session.tcpListenerLocalAddressV6;
    final quicListenerV4 = await _session.quicListenerLocalAddressV4;
    final quicListenerV6 = await _session.quicListenerLocalAddressV6;

    if (isClosed) {
      return;
    }

    emit(state.copyWith(
      tcpListenerV4: tcpListenerV4 ?? '',
      tcpListenerV6: tcpListenerV6 ?? '',
      quicListenerV4: quicListenerV4 ?? '',
      quicListenerV6: quicListenerV6 ?? '',
    ));

    final localIPv4 = await _networkInfo.getWifiIP();

    if (isClosed) {
      return;
    }

    if (localIPv4 != null) {
      final port = _extractPort(quicListenerV4 ?? tcpListenerV4 ?? '');
      emit(state.copyWith(localAddressV4: "$localIPv4:$port"));
    } else {
      emit(state.copyWith(localAddressV4: ""));
    }

    final localIPv6 = await _networkInfo.getWifiIPv6();

    if (isClosed) {
      return;
    }

    if (localIPv6 != null) {
      final port = _extractPort(quicListenerV6 ?? tcpListenerV6 ?? '');
      emit(state.copyWith(localAddressV6: "[$localIPv6]:$port"));
    } else {
      emit(state.copyWith(localAddressV6: ""));
    }

    final externalAddressV4 = await _session.externalAddressV4 ?? "";

    if (isClosed) {
      return;
    }

    emit(state.copyWith(externalAddressV4: externalAddressV4));

    final externalAddressV6 = await _session.externalAddressV6 ?? "";

    if (isClosed) {
      return;
    }

    emit(state.copyWith(externalAddressV6: externalAddressV6));
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
