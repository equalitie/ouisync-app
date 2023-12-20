import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/peer_set.dart';
import '../utils/utils.dart';
import '../widgets/dialogs/add_peer_dialog.dart';

class PeerList extends StatelessWidget {
  final PeerSetCubit _cubit;

  PeerList(this._cubit);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.current.labelPeers)),
        body: BlocBuilder<PeerSetCubit, PeerSet>(
          bloc: _cubit,
          builder: (context, state) => ListView(
            padding: Dimensions.paddingContents,
            children: _buildItems(context, state),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_rounded),
          onPressed: () => _addPeer(context),
        ),
      );

  List<Widget> _buildItems(BuildContext context, PeerSet peers) {
    var connected = false;
    var connecting = false;
    var peerIndex = 1;

    var widgets = <Widget>[];

    for (final entry in peers.grouped.entries) {
      final runtimeId = entry.key.runtimeId;

      if (runtimeId != null) {
        if (!connected) {
          connected = true;
          widgets.add(_buildHeader(context, 'Connected'));
        }

        widgets.add(_buildPeerHeader(context, peerIndex++, runtimeId));
      } else {
        if (!connecting) {
          connecting = true;
          widgets.add(_buildHeader(context, 'Connecting'));
        }
      }

      widgets.addAll(entry.value.map((peer) => _buildPeer(context, peer)));
    }

    return widgets;
  }

  Widget _buildHeader(BuildContext context, String title) => Container(
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Text(title, style: context.theme.appTextStyle.titleLarge),
      );

  Widget _buildPeerHeader(BuildContext context, int index, String runtimeId) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.theme.dividerColor.withOpacity(0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text('#$index',
                  style: context.theme.appTextStyle.titleMedium),
            ),
            Expanded(
              flex: 16,
              child: Row(children: [
                Icon(Icons.person, size: Dimensions.sizeIconMicro),
                Expanded(
                  child: _LongText(
                    runtimeId,
                  ),
                )
              ]),
            ),
          ],
        ),
      );

  Widget _buildPeer(BuildContext context, PeerInfo peer) => Container(
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Row(
          children: [
            Spacer(flex: 1),
            Expanded(
              flex: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LongText(peer.addr),
                  _buildBadges(context, peer),
                ],
              ),
            ),
            Expanded(flex: 2, child: _buildRemoveButton(context, peer)),
          ],
        ),
      );

  Widget _buildBadges(BuildContext context, PeerInfo peer) => Row(
        children: [
          _buildBadge(context, Text(_formatPeerProto(peer.proto))),
          _buildBadge(
            context,
            Row(
              children: [
                Icon(peer.source == PeerSource.listener
                    ? Icons.arrow_downward
                    : Icons.arrow_upward),
                Text(_formatPeerSource(peer.source)),
              ],
            ),
          ),
          if (peer.state != PeerStateKind.active)
            _buildBadge(context, Text(_formatPeerState(peer.state))),
        ],
      );

  Widget _buildBadge(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.tertiaryContainer;
    final fg = theme.colorScheme.onTertiaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      margin: EdgeInsets.symmetric(horizontal: 1.0),
      child: _applyStyle(
        fgColor: fg,
        bgColor: bg,
        contentSize: 10.0,
        child: child,
      ),
    );
  }

  Widget _applyStyle({
    Color? fgColor,
    Color? bgColor,
    double? contentSize,
    required Widget child,
  }) =>
      IconTheme(
        data: IconThemeData(color: fgColor, size: contentSize),
        child: DefaultTextStyle(
          style: TextStyle(color: fgColor, fontSize: contentSize),
          child: child,
        ),
      );

  Widget _buildRemoveButton(BuildContext context, PeerInfo peer) =>
      (peer.source == PeerSource.userProvided)
          ? IconButton(
              icon: Icon(
                Icons.close_rounded,
              ),
              iconSize: Dimensions.sizeIconMicro,
              visualDensity: VisualDensity.compact,
              onPressed: () => _removePeer(context, peer),
            )
          : Container();

  // TODO: i18n this
  String _formatPeerState(PeerStateKind state) => switch (state) {
        PeerStateKind.known => 'Known',
        PeerStateKind.connecting => 'Connecting',
        PeerStateKind.handshaking => 'Handshaking',
        PeerStateKind.active => 'Active',
      };

  // TODO: i18n this
  String _formatPeerSource(PeerSource source) => switch (source) {
        PeerSource.dht => 'DHT',
        PeerSource.listener => 'Listener',
        PeerSource.localDiscovery => 'Local discovery',
        PeerSource.peerExchange => 'Peer exchange',
        PeerSource.userProvided => 'User provided',
      };

  String _formatPeerProto(PeerProto proto) => switch (proto) {
        PeerProto.tcp => 'TCP',
        PeerProto.quic => 'QUIC',
      };

  Future<void> _addPeer(BuildContext context) async {
    final address = await showDialog<String>(
      context: context,
      builder: (context) => AddPeerDialog(),
    );

    if (address == null) {
      return;
    }

    await _cubit.addPeer(address);

    showSnackBar(context, message: 'Peer added');
  }

  Future<void> _removePeer(BuildContext context, PeerInfo peer) async {
    await _cubit.removePeer(peer.addr);

    showSnackBar(context, message: 'Peer removed');
  }
}

class _LongText extends StatelessWidget {
  final String text;

  _LongText(this.text);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: text,
        triggerMode: TooltipTriggerMode.tap,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
        ),
      );
}
