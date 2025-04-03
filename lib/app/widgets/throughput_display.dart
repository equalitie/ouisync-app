import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/format.dart';

/// Widget that displays upload and download throughput.
class ThroughputDisplay extends StatelessWidget {
  const ThroughputDisplay(
    this.stats, {
    super.key,
    this.size,
    this.orientation = Orientation.landscape,
  });

  final Stats stats;
  final double? size;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: size,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        child: Builder(
          builder: (context) => IconTheme(
              data: IconThemeData(
                size: DefaultTextStyle.of(context).style.fontSize,
              ),
              child: switch (orientation) {
                Orientation.landscape => Row(children: _buildCells(context)),
                Orientation.portrait => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildCells(context)),
              }),
        ),
      );

  List<Widget> _buildCells(BuildContext context) => [
        _buildCell(
          context,
          stats.throughputRx,
          Icon(Icons.download, color: Colors.blue),
        ),
        _buildCell(
          context,
          stats.throughputTx,
          Icon(Icons.upload, color: Colors.orange),
        ),
      ];

  Widget _buildCell(
    BuildContext context,
    int value,
    Icon icon,
  ) =>
      Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(formatThroughput(value)),
            icon,
          ],
        ),
      );
}

class LiveThroughputDisplay extends StatelessWidget {
  const LiveThroughputDisplay(
    this.stream, {
    super.key,
    this.size,
    this.orientation = Orientation.landscape,
  });

  final Stream<Stats> stream;
  final double? size;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) => StreamBuilder<Stats>(
        stream: stream,
        builder: (context, snapshot) => ThroughputDisplay(
          snapshot.data ??
              Stats(
                bytesRx: 0,
                bytesTx: 0,
                throughputTx: 0,
                throughputRx: 0,
              ),
          size: size,
          orientation: orientation,
        ),
      );
}
