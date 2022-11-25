import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/peer_list.dart';
import '../../utils/utils.dart';

import 'navigation_tile.dart';

class NetworkSection extends AbstractSettingsSection {
  final Future<NatDetection> _natDetection;

  NetworkSection(this._natDetection);

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: Text(S.current.titleNetwork),
        tiles: [
          _buildConnectivityTypeTile(context),
          _buildPortForwardingTile(context),
          _buildLocalDiscoveryTile(context),
          _buildSyncOnMobileSwitch(context),
          ..._buildConnectivityInfoTiles(context),
          _buildPeerListTile(context),
          _buildNatDetectionTile(context),
        ],
      );

  AbstractSettingsTile _buildConnectivityTypeTile(BuildContext context) =>
      CustomSettingsTile(
        child: BlocBuilder<PowerControl, PowerControlState>(
          builder: (context, state) => SettingsTile(
            leading: Icon(Icons.wifi),
            title: Text(Strings.connectionType),
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_connectivityTypeName(state.connectivityType)),
                if (state.networkDisabledReason != null)
                  Text('(${state.networkDisabledReason!})'),
              ],
            ),
            trailing: (state.isNetworkEnabled ?? true)
                ? null
                : Icon(Icons.warning, color: Constants.warningColor),
          ),
        ),
      );

  AbstractSettingsTile _buildPortForwardingTile(BuildContext context) =>
      CustomSettingsTile(
        child: BlocSelector<PowerControl, PowerControlState, bool>(
          selector: (state) => state.portForwardingEnabled,
          builder: (context, value) => SettingsTile.switchTile(
            initialValue: value,
            onToggle: (value) {
              final powerControl = context.read<PowerControl>();
              unawaited(powerControl.setPortForwardingEnabled(value));
            },
            title: Text('UPnP'),
            leading: Icon(Icons.router),
          ),
        ),
      );

  AbstractSettingsTile _buildLocalDiscoveryTile(BuildContext context) =>
      CustomSettingsTile(
        child: BlocSelector<PowerControl, PowerControlState, bool>(
          selector: (state) => state.localDiscoveryEnabled,
          builder: (context, value) => SettingsTile.switchTile(
            initialValue: value,
            onToggle: (value) {
              final powerControl = context.read<PowerControl>();
              unawaited(powerControl.setLocalDiscoveryEnabled(value));
            },
            title: Text('Local Discovery'), // TODO: localize
            leading: Icon(Icons.broadcast_on_personal),
          ),
        ),
      );

  AbstractSettingsTile _buildSyncOnMobileSwitch(BuildContext context) =>
      CustomSettingsTile(
          child: BlocSelector<PowerControl, PowerControlState, bool>(
        selector: (state) => state.syncOnMobile,
        builder: (context, value) => SettingsTile.switchTile(
          initialValue: value,
          onToggle: (value) {
            final powerControl = context.read<PowerControl>();
            unawaited(powerControl.setSyncOnMobileEnabled(value));
          },
          title: Text('Sync while using mobile data'),
          leading: Icon(Icons.mobile_screen_share),
        ),
      ));

  List<AbstractSettingsTile> _buildConnectivityInfoTiles(
          BuildContext context) =>
      [
        _buildConnectivityInfoTile(
          Strings.labelTcpListenerEndpointV4,
          Icons.computer,
          (state) => state.tcpListenerV4,
        ),
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
        ),
      ];

  AbstractSettingsTile _buildConnectivityInfoTile(
    String title,
    IconData icon,
    String Function(ConnectivityInfoState) selector,
  ) =>
      CustomSettingsTile(
          child: BlocSelector<ConnectivityInfo, ConnectivityInfoState, String>(
              selector: selector,
              builder: (context, value) {
                if (value.isNotEmpty) {
                  return SettingsTile(
                    leading: Icon(icon),
                    title: Text(title),
                    value: Text(value),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }));

  AbstractSettingsTile _buildPeerListTile(BuildContext context) =>
      CustomSettingsTile(
        child: BlocBuilder<PeerSetCubit, PeerSet>(
          builder: (context, state) => NavigationTile(
              leading: Icon(Icons.people),
              title: Text(S.current.labelPeers),
              value: Text(state.stats()),
              onPressed: (context) {
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
      );

  AbstractSettingsTile _buildNatDetectionTile(BuildContext context) =>
      CustomSettingsTile(
          child: FutureBuilder<NatDetection>(
              future: _natDetection,
              builder:
                  (BuildContext context, AsyncSnapshot<NatDetection> snapshot) {
                final natDetection = snapshot.data;
                if (natDetection == null) {
                  return SizedBox.shrink();
                }

                return BlocBuilder<NatDetection, NatDetectionType>(
                    bloc: natDetection,
                    builder: (context, type) {
                      return SettingsTile(
                        leading: Icon(Icons.nat),
                        title: Text("NAT type"),
                        value: Text(type.message()),
                      );
                    });
              }));
}

String _connectivityTypeName(ConnectivityResult result) {
  switch (result) {
    case ConnectivityResult.bluetooth:
      return "Bluetooth";
    case ConnectivityResult.wifi:
      return "WiFi";
    case ConnectivityResult.mobile:
      return "Mobile";
    case ConnectivityResult.ethernet:
      return "Ethernet";
    case ConnectivityResult.vpn:
      return "VPN";
    case ConnectivityResult.none:
      return "None";
  }
}
