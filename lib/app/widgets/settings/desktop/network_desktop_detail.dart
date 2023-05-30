import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/utils/utils.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../../../pages/peer_list.dart';

class NetworkDesktopDetail extends StatelessWidget {
  const NetworkDesktopDetail({required this.natDetection});

  final Future<NatDetection> natDetection;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildConnectivityTile(context),
      _buildPortForwardingTile(context),
      _buildLocalDiscoveryTile(context),
      _buildSyncOnMobileSwitch(context),
      ..._buildConnectivityInfoTiles(context),
      _buildPeerListTile(context),
      _buildNatDetectionTile(context)
    ]);
  }

  Widget _buildConnectivityTile(BuildContext context) => Wrap(children: [
        BlocBuilder<PowerControl, PowerControlState>(
            builder: (context, state) => ListTile(
                leading: Icon(Icons.wifi),
                title: Text(Strings.connectionType),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_connectivityTypeName(state.connectivityType)),
                    if (state.networkDisabledReason != null)
                      Text('(${state.networkDisabledReason!})'),
                  ],
                ),
                trailing: (state.isNetworkEnabled ?? true)
                    ? null
                    : Icon(Icons.warning, color: Constants.warningColor))),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildPortForwardingTile(BuildContext context) => Wrap(children: [
        BlocSelector<PowerControl, PowerControlState, bool>(
            selector: (state) => state.portForwardingEnabled,
            builder: (context, value) => SwitchListTile.adaptive(
                value: value,
                onChanged: (value) {
                  final powerControl = context.read<PowerControl>();
                  unawaited(powerControl.setPortForwardingEnabled(value));
                },
                title: Text('UPnP'),
                secondary: Icon(Icons.router))),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildLocalDiscoveryTile(BuildContext context) => Wrap(children: [
        BlocSelector<PowerControl, PowerControlState, bool>(
            selector: (state) => state.localDiscoveryEnabled,
            builder: (context, value) => SwitchListTile.adaptive(
                value: value,
                onChanged: (value) {
                  final powerControl = context.read<PowerControl>();
                  unawaited(powerControl.setLocalDiscoveryEnabled(value));
                },
                title: Text(S.current.messageLocalDiscovery),
                secondary: Icon(Icons.broadcast_on_personal))),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildSyncOnMobileSwitch(BuildContext context) => Wrap(children: [
        BlocSelector<PowerControl, PowerControlState, bool>(
            selector: (state) => state.syncOnMobile,
            builder: (context, value) => SwitchListTile.adaptive(
                value: value,
                onChanged: (value) {
                  final powerControl = context.read<PowerControl>();
                  unawaited(powerControl.setSyncOnMobileEnabled(value));
                },
                title: Text(S.current.messageSyncMobileData),
                secondary: Icon(Icons.mobile_screen_share))),
        Dimensions.desktopSettingDivider
      ]);

  List<Widget> _buildConnectivityInfoTiles(BuildContext context) => [
        _buildConnectivityInfoTile(Strings.labelTcpListenerEndpointV4,
            Icons.computer, (state) => state.tcpListenerV4),
        _buildConnectivityInfoTile(
          Strings.labelTcpListenerEndpointV6,
          Icons.computer,
          (state) => state.tcpListenerV6,
        ),
        _buildConnectivityInfoTile(
          Strings.labelQuicListenerEndpointV4,
          Icons.computer,
          (state) => state.quicListenerV4,
        ),
        _buildConnectivityInfoTile(
          Strings.labelQuicListenerEndpointV6,
          Icons.computer,
          (state) => state.quicListenerV6,
        ),
        _buildConnectivityInfoTile(
          Strings.labelExternalIP,
          Icons.cloud_outlined,
          (state) => state.externalIP,
        ),
        _buildConnectivityInfoTile(
          Strings.labelLocalIPv4,
          Icons.lan_outlined,
          (state) => state.localIPv4,
        ),
        _buildConnectivityInfoTile(
          Strings.labelLocalIPv6,
          Icons.lan_outlined,
          (state) => state.localIPv6,
        )
      ];

  Widget _buildConnectivityInfoTile(String title, IconData icon,
          String Function(ConnectivityInfoState) selector) =>
      Container(
          child: BlocSelector<ConnectivityInfo, ConnectivityInfoState, String>(
              selector: selector,
              builder: (context, value) {
                if (value.isNotEmpty) {
                  return Wrap(children: [
                    ListTile(
                      leading: Icon(icon),
                      title: Text(title),
                      subtitle: Text(value),
                    ),
                    Dimensions.desktopSettingDivider
                  ]);
                } else {
                  return SizedBox.shrink();
                }
              }));

  Widget _buildPeerListTile(BuildContext context) => Wrap(children: [
        BlocBuilder<PeerSetCubit, PeerSet>(
          builder: (context, state) => ListTile(
              leading: Icon(Icons.people),
              title: Text(S.current.labelPeers),
              subtitle: Text(state.stats()),
              onTap: () {
                final peerSetCubit = context.read<PeerSetCubit>();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                              value: peerSetCubit,
                              child: PeerList(),
                            )));
              }),
        ),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildNatDetectionTile(BuildContext context) => Container(
      child: FutureBuilder<NatDetection>(
          future: natDetection,
          builder:
              (BuildContext context, AsyncSnapshot<NatDetection> snapshot) {
            final natDetection = snapshot.data;
            if (natDetection == null) {
              return SizedBox.shrink();
            }

            return BlocBuilder<NatDetection, NatDetectionType>(
                bloc: natDetection,
                builder: (context, type) {
                  return ListTile(
                    leading: Icon(Icons.nat),
                    title: Text(S.current.messageNATType),
                    subtitle: Text(type.message()),
                  );
                });
          }));

  String _connectivityTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
        return S.current.messageBluetooth;
      case ConnectivityResult.wifi:
        return S.current.messageWiFi;
      case ConnectivityResult.mobile:
        return S.current.messageMobile;
      case ConnectivityResult.ethernet:
        return S.current.messageEthernet;
      case ConnectivityResult.vpn:
        return S.current.messageVPN;
      case ConnectivityResult.none:
        return S.current.messageNone;
      case ConnectivityResult.other:
        return 'other';
    }
  }
}
