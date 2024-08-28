import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/format.dart';

/// Widget that displays upload and download throughput.
class ThroughputDisplay extends StatelessWidget {
  const ThroughputDisplay(this.stats, {super.key, this.size});

  final NetworkStats stats;
  final double? size;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
        style: TextStyle(fontSize: size),
        child: Builder(
          builder: (context) => IconTheme(
            data: IconThemeData(
              size: DefaultTextStyle.of(context).style.fontSize,
            ),
            child: Row(
              children: [
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
              ],
            ),
          ),
        ),
      );

  Widget _buildCell(
    BuildContext context,
    int value,
    Icon icon,
  ) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            Text(formatThroughput(value)),
          ],
        ),
      );
}

class LiveThroughputDisplay extends StatelessWidget {
  const LiveThroughputDisplay(this.stream, {super.key, this.size});

  final Stream<NetworkStats> stream;
  final double? size;

  @override
  Widget build(BuildContext context) => StreamBuilder<NetworkStats>(
        stream: stream,
        builder: (context, snapshot) => ThroughputDisplay(
          snapshot.data ?? NetworkStats(),
          size: size,
        ),
      );
}
