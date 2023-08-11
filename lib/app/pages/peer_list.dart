import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/peer_set.dart';
import '../utils/utils.dart';

class PeerList extends StatelessWidget {
  late final TextStyle? bodyMicroStyle;

  @override
  Widget build(BuildContext context) {
    bodyMicroStyle = context.theme.appTextStyle.bodyMicro;

    return Scaffold(
      appBar: AppBar(title: Text(S.current.labelPeers)),
      body: BlocBuilder<PeerSetCubit, PeerSet>(
        builder: (context, state) => SingleChildScrollView(
          child: Container(
            padding: Dimensions.paddingContents,
            child: _buildTable(context, state.grouped),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, peers) => Table(
        defaultColumnWidth: const FlexColumnWidth(),
        columnWidths: const <int, TableColumnWidth>{
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        children: <TableRow>[
          _buildHeaderRow(context),
          ..._buildDataRows(context, peers),
        ],
      );

  TableRow _buildHeaderRow(BuildContext context) {
    final style = context.theme.appTextStyle.titleSmall;

    return TableRow(children: <TableCell>[
      _buildCell(Text('IP', style: style)),
      _buildCell(Text('Port', style: style)),
      _buildCell(Text('Source', style: style)),
      _buildCell(Text('ID', style: style)),
    ]);
  }

  List<TableRow> _buildDataRows(
    BuildContext context,
    SplayTreeMap<PeerKey, List<PeerInfo>> peers,
  ) =>
      peers.entries
          .expand((entry) => _buildGroup(
                context,
                entry.value,
                entry.key.runtimeId,
              ))
          .toList();

  Iterable<TableRow> _buildGroup(
    BuildContext context,
    List<PeerInfo> peers,
    String runtimeId,
  ) =>
      Iterable.generate(peers.length,
          (index) => _buildGroupRow(context, index, peers[index], runtimeId));

  TableRow _buildGroupRow(
    BuildContext context,
    int index,
    PeerInfo peer,
    String runtimeId,
  ) =>
      TableRow(
        children: <TableCell>[
          _buildCell(_LongText(peer.ip, style: bodyMicroStyle)),
          _buildCell(Text(peer.port.toString(), style: bodyMicroStyle)),
          _buildCell(_buildSource(context, peer.source)),
          index == 0
              ? _buildCell(_buildId(context, peer.state, runtimeId))
              : TableCell(child: SizedBox.shrink()),
        ],
        decoration: index == 0
            ? BoxDecoration(
                border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ))
            : null,
      );

  TableCell _buildCell(Widget child) => TableCell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
          child: child,
        ),
      );

  Widget _buildId(
    BuildContext context,
    String state,
    String runtimeId,
  ) =>
      runtimeId.isNotEmpty
          ? _buildActiveId(context, runtimeId)
          : _buildInactiveId(context, state);

  Widget _buildActiveId(BuildContext context, String runtimeId) =>
      Row(children: [
        Icon(Icons.person, size: Dimensions.sizeIconBadge),
        Expanded(child: _LongText(runtimeId, style: bodyMicroStyle)),
      ]);

  Widget _buildInactiveId(BuildContext context, String state) {
    final color = Theme.of(context).disabledColor;

    return Row(children: [
      Icon(Icons.person_outline, size: Dimensions.sizeIconBadge, color: color),
      Text(
        state,
        style: bodyMicroStyle?.copyWith(color: color),
      )
    ]);
  }

  Widget _buildSource(BuildContext context, String source) {
    final icon =
        source == 'Listener' ? Icons.arrow_downward : Icons.arrow_upward;

    return Row(
      children: [
        Icon(icon, size: Dimensions.sizeIconBadge),
        Text(source, style: bodyMicroStyle),
      ],
    );
  }
}

class _LongText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  _LongText(this.text, {this.style});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: text,
        triggerMode: TooltipTriggerMode.tap,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      );
}
