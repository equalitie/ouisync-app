import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:r_get_ip/r_get_ip.dart';

class ConnectivityInfoState extends Equatable {
  final String tcpListenerV4;
  final String tcpListenerV6;
  final String quicListenerV4;
  final String quicListenerV6;

  final String localIPv4;
  final String localIPv6;

  final String externalIP;

  ConnectivityInfoState({
    this.tcpListenerV4 = "",
    this.tcpListenerV6 = "",
    this.quicListenerV4 = "",
    this.quicListenerV6 = "",
    this.localIPv4 = "",
    this.localIPv6 = "",
    this.externalIP = "",
  });

  ConnectivityInfoState copyWith({
    String? tcpListenerV4,
    String? tcpListenerV6,
    String? quicListenerV4,
    String? quicListenerV6,
    String? localIPv4,
    String? localIPv6,
    String? externalIP,
  }) =>
      ConnectivityInfoState(
        tcpListenerV4: tcpListenerV4 ?? this.tcpListenerV4,
        tcpListenerV6: tcpListenerV4 ?? this.tcpListenerV6,
        quicListenerV4: quicListenerV4 ?? this.quicListenerV4,
        quicListenerV6: quicListenerV6 ?? this.quicListenerV6,
        localIPv4: localIPv4 ?? this.localIPv4,
        localIPv6: localIPv6 ?? this.localIPv6,
        externalIP: externalIP ?? this.externalIP,
      );

  @override
  List<Object?> get props => [
        tcpListenerV4,
        tcpListenerV6,
        quicListenerV4,
        quicListenerV4,
        localIPv4,
        localIPv6,
        externalIP,
      ];
}

class ConnectivityInfo extends Cubit<ConnectivityInfoState> {
  final Session _session;
  final _networkInfo = NetworkInfo();
  final _connectivity = Connectivity();

  ConnectivityInfo({required Session session})
      : _session = session,
        super(ConnectivityInfoState());

  Future<void> update() async {
    emit(state.copyWith(
      tcpListenerV4: _session.tcpListenerLocalAddressV4 ?? "",
      tcpListenerV6: _session.tcpListenerLocalAddressV6 ?? "",
      quicListenerV4: _session.quicListenerLocalAddressV4 ?? "",
      quicListenerV6: _session.quicListenerLocalAddressV6 ?? "",
    ));

    // This really works only when connected using WiFi.
    final localIPv4 = await _networkInfo.getWifiIP();
    emit(state.copyWith(localIPv4: localIPv4 ?? ""));

    final localIPv6 = await _networkInfo.getWifiIPv6();
    emit(state.copyWith(localIPv6: localIPv6 ?? ""));

    // This works also when on mobile network, but doesn't show IPv6 address if
    // IPv4 is used as primary.
    final internalIPStr = await RGetIp.internalIP;

    if (internalIPStr != null) {
      final internalIP = InternetAddress.tryParse(internalIPStr);

      if (internalIP != null) {
        if (state.localIPv4.isEmpty &&
            internalIP.type == InternetAddressType.IPv4) {
          emit(state.copyWith(localIPv4: internalIPStr));
        }

        if (state.localIPv6.isEmpty &&
            internalIP.type == InternetAddressType.IPv6) {
          emit(state.copyWith(localIPv6: internalIPStr));
        }
      }
    }

    final connectivity = await _connectivity.checkConnectivity();

    if (connectivity != ConnectivityResult.none) {
      final externalIP = await RGetIp.externalIP;
      emit(state.copyWith(externalIP: externalIP));
    }
  }
}
