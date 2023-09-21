import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:dart_ipify/dart_ipify.dart';

class ConnectivityInfoState extends Equatable {
  final String tcpListenerV4;
  final String tcpListenerV6;
  final String quicListenerV4;
  final String quicListenerV6;

  final String localIPv4;
  final String localIPv6;

  final String externalIPv4;
  final String externalIPv6;

  ConnectivityInfoState({
    this.tcpListenerV4 = "",
    this.tcpListenerV6 = "",
    this.quicListenerV4 = "",
    this.quicListenerV6 = "",
    this.localIPv4 = "",
    this.localIPv6 = "",
    this.externalIPv4 = "",
    this.externalIPv6 = "",
  });

  ConnectivityInfoState copyWith({
    String? tcpListenerV4,
    String? tcpListenerV6,
    String? quicListenerV4,
    String? quicListenerV6,
    String? localIPv4,
    String? localIPv6,
    String? externalIPv4,
    String? externalIPv6,
  }) =>
      ConnectivityInfoState(
        tcpListenerV4: tcpListenerV4 ?? this.tcpListenerV4,
        tcpListenerV6: tcpListenerV4 ?? this.tcpListenerV6,
        quicListenerV4: quicListenerV4 ?? this.quicListenerV4,
        quicListenerV6: quicListenerV6 ?? this.quicListenerV6,
        localIPv4: localIPv4 ?? this.localIPv4,
        localIPv6: localIPv6 ?? this.localIPv6,
        externalIPv4: externalIPv4 ?? this.externalIPv4,
        externalIPv6: externalIPv6 ?? this.externalIPv6,
      );

  @override
  List<Object?> get props => [
        tcpListenerV4,
        tcpListenerV6,
        quicListenerV4,
        quicListenerV4,
        localIPv4,
        localIPv6,
        externalIPv4,
        externalIPv6,
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
    final tcpListenerV4 = await _session.tcpListenerLocalAddressV4 ?? "";
    final tcpListenerV6 = await _session.tcpListenerLocalAddressV6 ?? "";
    final quicListenerV4 = await _session.quicListenerLocalAddressV4 ?? "";
    final quicListenerV6 = await _session.quicListenerLocalAddressV6 ?? "";

    if (isClosed) {
      return;
    }

    emit(state.copyWith(
      tcpListenerV4: tcpListenerV4,
      tcpListenerV6: tcpListenerV6,
      quicListenerV4: quicListenerV4,
      quicListenerV6: quicListenerV6,
    ));

    // This really works only when connected using WiFi.
    final localIPv4 = await _networkInfo.getWifiIP();

    if (isClosed) {
      return;
    }

    emit(state.copyWith(localIPv4: localIPv4 ?? ""));

    /// The plugin network_info_plus is currently (2023-02-01) missing the
    /// implementation for this method on desktop platforms (except macOS).
    ///
    /// The native implementation doesn't have a method for IPv6, just the one
    /// for the WiFi IP (getWifiIP), which uses the address family AF_INET
    /// (Return only IPv4 addresses associated with adapters with IPv4 enabled.),
    /// or AF_UNSPEC (Return both IPv4 and IPv6 addresses associated with adapters
    /// with IPv4 or IPv6 enabled.), which doesn't guarantee an IPv6 address can
    /// be retrieved, and most likely only IPv4 would be available.
    ///
    /// The native implementation in the Windows project for the method getWifiIP
    /// (and where the getWifiIPv6 should be located) can be found here:
    /// https://github.com/fluttercommunity/plus_plugins/blob/a8d38112e069d738c91dc590d1866a8afc6a4bbd/packages/network_info_plus/network_info_plus/windows/network_info.cpp#L74
    String? localIPv6;
    if (Platform.isAndroid || Platform.isIOS) {
      localIPv6 = await _networkInfo.getWifiIPv6();

      if (isClosed) {
        return;
      }
    }

    emit(state.copyWith(localIPv6: localIPv6 ?? ""));

    String? extIpStr;

    extIpStr = await Ipify.ipv64();

    if (isClosed) {
      return;
    }

    bool gotIpv4 = false;

    if (extIpStr != null) {
      final extIp = InternetAddress.tryParse(extIpStr);

      if (extIp != null) {
        if (extIp.type == InternetAddressType.IPv4) {
          gotIpv4 = true;
          emit(state.copyWith(externalIPv4: extIpStr));
        }

        if (extIp.type == InternetAddressType.IPv6) {
          emit(state.copyWith(externalIPv6: extIpStr));
        }
      }
    }

    if (!gotIpv4) {
      final connectivity = await _connectivity.checkConnectivity();

      if (connectivity != ConnectivityResult.none) {
        final extIpStr = await Ipify.ipv4();

        if (isClosed) {
          return;
        }

        final extIp = InternetAddress.tryParse(extIpStr);

        if (extIp != null) {
          if (extIp.type == InternetAddressType.IPv4) {
            emit(state.copyWith(externalIPv4: extIpStr));
          }

          if (extIp.type == InternetAddressType.IPv6) {
            emit(state.copyWith(externalIPv6: extIpStr));
          }
        }
      }
    }
  }
}
