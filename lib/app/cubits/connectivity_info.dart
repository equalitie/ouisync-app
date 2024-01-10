import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../utils/log.dart';

class ConnectivityInfoState extends Equatable {
  final String tcpListenerV4;
  final String tcpListenerV6;
  final String quicListenerV4;
  final String quicListenerV6;

  final List<String> localAddresses;
  final List<String> externalAddresses;

  ConnectivityInfoState({
    this.tcpListenerV4 = "",
    this.tcpListenerV6 = "",
    this.quicListenerV4 = "",
    this.quicListenerV6 = "",
    this.localAddresses = const [],
    this.externalAddresses = const [],
  });

  ConnectivityInfoState copyWith({
    String? tcpListenerV4,
    String? tcpListenerV6,
    String? quicListenerV4,
    String? quicListenerV6,
    List<String>? localAddresses,
    List<String>? externalAddresses,
  }) =>
      ConnectivityInfoState(
        tcpListenerV4: tcpListenerV4 ?? this.tcpListenerV4,
        tcpListenerV6: tcpListenerV4 ?? this.tcpListenerV6,
        quicListenerV4: quicListenerV4 ?? this.quicListenerV4,
        quicListenerV6: quicListenerV6 ?? this.quicListenerV6,
        localAddresses: localAddresses ?? this.localAddresses,
        externalAddresses: externalAddresses ?? this.externalAddresses,
      );

  @override
  List<Object?> get props => [
        tcpListenerV4,
        tcpListenerV6,
        quicListenerV4,
        quicListenerV4,
        localAddresses,
        externalAddresses,
      ];
}

class ConnectivityInfo extends Cubit<ConnectivityInfoState> with AppLogger {
  final Session _session;
  final _networkInfo = NetworkInfo();

  ConnectivityInfo(Session session)
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
    final localIPv6 = (Platform.isAndroid || Platform.isIOS)
        ? await _networkInfo.getWifiIPv6()
        : null;

    if (isClosed) {
      return;
    }

    emit(state.copyWith(
      localAddresses: [localIPv4, localIPv6].whereType<String>().toList(),
    ));

    emit(state.copyWith(externalAddresses: await _session.externalAddresses));
  }
}
