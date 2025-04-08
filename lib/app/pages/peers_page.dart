import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show PeerSet, PeerSetCubit;
import '../utils/utils.dart' show AppThemeExtension, Dimensions, ThemeGetter;
import '../widgets/widgets.dart'
    show DirectionalAppBar, LongText, LiveThroughputDisplay, ThroughputDisplay;
import 'pages.dart' show UserProvidedPeersPage;

const double _contentSize = 12.0;

class PeersPage extends StatefulWidget {
  final Session session;
  final PeerSetCubit cubit;

  PeersPage(this.session, this.cubit);

  @override
  State<PeersPage> createState() => _PeersPageState();
}

class _PeersPageState extends State<PeersPage> {
  Stream<Stats> get _networkStatsStream => Stream.periodic(Duration(seconds: 1))
      .asyncMapSample((_) => widget.session.getNetworkStats());

  @override
  void initState() {
    super.initState();
    widget.cubit.setAutoRefresh(Duration(seconds: 1));
  }

  @override
  void dispose() {
    widget.cubit.setAutoRefresh(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DirectionalAppBar(
          title: Row(
            children: [
              Text(S.current.labelPeers),
              Spacer(),
              LiveThroughputDisplay(
                _networkStatsStream,
                size: Theme.of(context).textTheme.labelSmall?.fontSize,
                orientation: Orientation.portrait,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              tooltip: 'User provided peers',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProvidedPeersPage(widget.session),
                ),
              ),
            )
          ],
        ),
        body: BlocBuilder<PeerSetCubit, PeerSet>(
          bloc: widget.cubit,
          builder: (context, state) => ListView(
            padding: Dimensions.paddingContents,
            children: _buildItems(context, state),
          ),
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
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 4.0,
          vertical: 8.0,
        ),
        child: Text(title, style: context.theme.appTextStyle.titleLarge),
      );

  Widget _buildPeerHeader(BuildContext context, int index, String runtimeId) =>
      Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 4.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(
              color: context.theme.dividerColor.withAlpha(128),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 0,
              child: Text('#$index',
                  style: context.theme.appTextStyle.titleMedium),
            ),
            Expanded(
              flex: 15,
              child: Row(children: [
                Icon(Icons.person, size: Dimensions.sizeIconMicro),
                Expanded(
                  child: LongText(
                    runtimeId,
                  ),
                )
              ]),
            ),
          ],
        ),
      );

  Widget _buildPeer(BuildContext context, PeerInfo peer) => Container(
        padding: EdgeInsetsDirectional.all(4.0),
        child: Row(
          children: [
            Spacer(flex: 1),
            Expanded(
              flex: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LongText(peer.addr),
                  _buildDetails(context, peer),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildDetails(BuildContext context, PeerInfo peer) => Row(
        children: [
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
          if (peer.state is! PeerStateActive)
            _buildBadge(context, Text(_formatPeerState(peer.state))),
          Spacer(),
          ThroughputDisplay(peer.stats, size: _contentSize),
        ],
      );

  Widget _buildBadge(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.tertiaryContainer;
    final fg = theme.colorScheme.onTertiaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadiusDirectional.circular(4.0),
      ),
      padding: EdgeInsetsDirectional.symmetric(vertical: 2.0, horizontal: 4.0),
      margin: EdgeInsetsDirectional.symmetric(horizontal: 1.0),
      child: _applyStyle(
        fgColor: fg,
        bgColor: bg,
        contentSize: _contentSize,
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

  // TODO: i18n this
  String _formatPeerState(PeerState state) => switch (state) {
        PeerStateKnown() => 'Known',
        PeerStateConnecting() => 'Connecting',
        PeerStateHandshaking() => 'Handshaking',
        PeerStateActive() => 'Active',
      };

  // TODO: i18n this
  String _formatPeerSource(PeerSource source) => switch (source) {
        PeerSource.dht => 'DHT',
        PeerSource.listener => 'Listener',
        PeerSource.localDiscovery => 'Local discovery',
        PeerSource.peerExchange => 'Peer exchange',
        PeerSource.userProvided => 'User provided',
      };
}
