import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show Session;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/peers_page.dart';
import '../../utils/stage.dart';
import '../../utils/peer_addr.dart';
import '../../utils/utils.dart';
import '../widgets.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class NetworkSection extends SettingsSection {
  NetworkSection({
    required this.stage,
    required this.session,
    required this.connectivityInfo,
    required this.natDetection,
    required this.peerSet,
    required this.powerControl,
  }) : super(
         key: GlobalKey(debugLabel: 'key_network_section'),
         title: S.current.titleNetwork,
       );

  final Stage stage;
  final Session session;
  final ConnectivityInfo connectivityInfo;
  final NatDetection natDetection;
  final PeerSetCubit peerSet;
  final PowerControl powerControl;

  TextStyle? bodyStyle;
  TextStyle? subtitleStyle;
  TextStyle? subtitleWarningStyle;

  @override
  List<Widget> buildTiles(BuildContext context) {
    bodyStyle = context.theme.appTextStyle.bodyMedium;
    subtitleStyle = context.theme.appTextStyle.bodySmall;
    subtitleWarningStyle = subtitleStyle!.copyWith(
      color: Constants.warningColor,
    );

    return [
      _buildConnectivityTypeTile(),
      _buildPortForwardingTile(),
      _buildLocalDiscoveryTile(),
      _buildSyncOnMobileSwitch(),
      ..._buildConnectivityInfoTiles(),
      _buildPeerListTile(),
      _buildNatDetectionTile(),
    ];
  }

  Widget _buildConnectivityTypeTile() =>
      BlocBuilder<PowerControl, PowerControlState>(
        bloc: powerControl,
        builder: (context, state) => SettingsTile(
          leading: Icon(Icons.wifi),
          title: Text(S.current.labelConnectionType, style: bodyStyle),
          value: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _connectivityTypeName(state.connectivityType),
                style: subtitleStyle,
              ),
              if (state.internetConnectivityDisabledReason != null)
                Text(
                  state.internetConnectivityDisabledReason!,
                  style: subtitleWarningStyle,
                ),
            ],
          ),
          trailing: (state.isInternetConnectivityEnabled ?? true)
              ? null
              : Icon(Icons.warning, color: Constants.warningColor),
        ),
      );

  Widget _buildPortForwardingTile() =>
      BlocSelector<PowerControl, PowerControlState, bool>(
        bloc: powerControl,
        selector: (state) => state.userWantsPortForwardingEnabled,
        builder: (context, value) => SwitchSettingsTile(
          value: value,
          onChanged: (value) {
            unawaited(powerControl.setPortForwardingEnabled(value));
          },
          title: InfoBuble(
            child: Text(Strings.upNP, style: bodyStyle),
            title: S.current.titleUPnP,
            description: [TextSpan(text: S.current.messageInfoUPnP)],
          ),
          leading: Icon(Icons.router),
        ),
      );

  Widget _buildLocalDiscoveryTile() =>
      BlocBuilder<PowerControl, PowerControlState>(
        bloc: powerControl,
        builder: (context, state) => SwitchSettingsTile(
          value: state.userWantsLocalDiscoveryEnabled,
          onChanged: (value) {
            unawaited(powerControl.setLocalDiscoveryEnabled(value));
          },
          title: InfoBuble(
            child: Text(S.current.messageLocalDiscovery, style: bodyStyle),
            title: S.current.messageLocalDiscovery,
            description: [TextSpan(text: S.current.messageInfoLocalDiscovery)],
          ),
          subtitle: () {
            final text = powerControl.state.localDiscoveryDisabledReason;
            return text != null
                ? Text(text, style: subtitleWarningStyle)
                : null;
          }(),
          leading: Icon(Icons.broadcast_on_personal),
        ),
      );

  Widget _buildSyncOnMobileSwitch() =>
      BlocSelector<PowerControl, PowerControlState, bool>(
        bloc: powerControl,
        selector: (state) => state.userWantsSyncOnMobileEnabled,
        builder: (context, value) => SwitchSettingsTile(
          value: value,
          onChanged: (value) {
            unawaited(powerControl.setSyncOnMobileEnabled(value));
          },
          title: InfoBuble(
            child: Text(S.current.messageSyncMobileData, style: bodyStyle),
            title: S.current.messageSyncMobileData,
            description: [TextSpan(text: S.current.messageInfoSyncMobileData)],
          ),
          leading: Icon(Icons.mobile_screen_share),
        ),
      );

  List<Widget> _buildConnectivityInfoTiles() => [
    _buildConnectivityInfoTile(
      S.current.labelTcpListenerEndpointV4,
      Icons.computer,
      (state) => _findListenerAddr(
        state.listenerAddrs,
        PeerProto.tcp,
        InternetAddressType.IPv4,
      ),
    ),
    _buildConnectivityInfoTile(
      S.current.labelTcpListenerEndpointV6,
      Icons.computer,
      (state) => _findListenerAddr(
        state.listenerAddrs,
        PeerProto.tcp,
        InternetAddressType.IPv6,
      ),
    ),
    _buildConnectivityInfoTile(
      S.current.labelQuicListenerEndpointV4,
      Icons.computer,
      (state) => _findListenerAddr(
        state.listenerAddrs,
        PeerProto.quic,
        InternetAddressType.IPv4,
      ),
    ),
    _buildConnectivityInfoTile(
      S.current.labelQuicListenerEndpointV6,
      Icons.computer,
      (state) => _findListenerAddr(
        state.listenerAddrs,
        PeerProto.quic,
        InternetAddressType.IPv6,
      ),
    ),
    _buildAddressTile(
      S.current.labelExternalIPv4,
      Icons.cloud_outlined,
      (state) => state.externalAddressV4,
    ),
    _buildAddressTile(
      S.current.labelExternalIPv6,
      Icons.cloud_outlined,
      (state) => state.externalAddressV6,
    ),
    _buildAddressTile(
      S.current.labelLocalIPv4,
      Icons.lan_outlined,
      (state) => state.localAddressV4,
    ),
    _buildAddressTile(
      S.current.labelLocalIPv6,
      Icons.lan_outlined,
      (state) => state.localAddressV6,
    ),
  ];

  Widget _buildConnectivityInfoTile(
    String title,
    IconData icon,
    String Function(ConnectivityInfoState) selector,
  ) => BlocSelector<ConnectivityInfo, ConnectivityInfoState, String>(
    bloc: connectivityInfo,
    selector: selector,
    builder: (context, value) {
      if (value.isNotEmpty) {
        return SettingsTile(
          leading: Icon(icon),
          title: Text(title, style: bodyStyle),
          value: Text(value, style: subtitleStyle),
        );
      } else {
        return SizedBox.shrink();
      }
    },
  );

  Widget _buildAddressTile(
    String title,
    IconData icon,
    String Function(ConnectivityInfoState) selector,
  ) => BlocSelector<ConnectivityInfo, ConnectivityInfoState, String>(
    bloc: connectivityInfo,
    selector: selector,
    builder: (context, address) {
      if (address.isNotEmpty) {
        return _AddressTile(
          icon: icon,
          title: title,
          titleStyle: bodyStyle,
          value: address,
          valueStyle: subtitleStyle,
          stage: stage,
        );
      } else {
        return SizedBox.shrink();
      }
    },
  );

  Widget _buildPeerListTile() => BlocBuilder<PeerSetCubit, PeerSet>(
    bloc: peerSet,
    builder: (context, state) => NavigationTile(
      leading: Icon(Icons.people),
      title: Text(S.current.labelPeers, style: bodyStyle),
      value: Text(state.numConnected.toString(), style: subtitleStyle),
      onTap: () {
        stage.push(
          MaterialPageRoute(
            builder: (context) =>
                PeersPage(session: session, cubit: peerSet, stage: stage),
          ),
        );
      },
    ),
  );

  Widget _buildNatDetectionTile() => BlocBuilder<NatDetection, NatBehavior>(
    bloc: natDetection,
    builder: (context, state) => SettingsTile(
      leading: Icon(Icons.nat),
      title: InfoBuble(
        child: Text(S.current.messageNATType, style: bodyStyle),
        title: S.current.messageNATType,
        description: [
          TextSpan(text: S.current.messageInfoNATType),
          Fields.linkTextSpan(
            '\n\n${S.current.messageNATOnWikipedia}',
            _launchNATOnWikipedia,
          ),
        ],
      ),
      value: Text(_natBehaviorText(state), style: subtitleStyle),
    ),
  );

  void _launchNATOnWikipedia() async {
    final title = Text(S.current.messageNATOnWikipedia);
    await Fields.openUrl(stage, title, Constants.natWikipediaUrl);
  }
}

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

class _AddressTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final Stage stage;

  const _AddressTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.stage,
    this.titleStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) => SettingsTile(
    leading: Icon(icon),
    title: Text(title, style: titleStyle),
    value: SelectionArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(value, style: valueStyle),
      ),
    ),
    trailing: IconButton(
      icon: Icon(Icons.copy),
      onPressed: () => _onCopyPressed(),
    ),
  );

  Future<void> _onCopyPressed() async {
    await Clipboard.setData(ClipboardData(text: value));
    stage.showSnackBar(S.current.messageCopiedToClipboard);
  }
}

// TODO: Localize these
String _natBehaviorText(NatBehavior nat) => switch (nat) {
  NatBehavior.pending => '...',
  NatBehavior.offline => 'Offline',
  NatBehavior.endpointIndependent => 'Endpoint independent',
  NatBehavior.addressDependent => 'Address dependent',
  NatBehavior.addressAndPortDependent => 'Address and port dependent',
  NatBehavior.unknown => 'Unknown',
};

String _findListenerAddr(
  List<PeerAddr> addrs,
  PeerProto proto,
  InternetAddressType type,
) =>
    addrs
        .where((addr) => addr.proto == proto && addr.addr.type == type)
        .map((addr) => addr.toString())
        .firstOrNull ??
    '';
