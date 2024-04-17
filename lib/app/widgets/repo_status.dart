import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:stream_transform/stream_transform.dart';

import '../cubits/repo.dart';
import '../cubits/state_monitor.dart';
import '../utils/extensions.dart';
import '../utils/log.dart';

const _iconSize = 20.0;
const _iconPadding = 2.0;
final _color = Colors.black.withOpacity(0.25);

/// Widget that displays repository status - it's sync progress and whether any sync activity is
/// ongoing.
class RepoStatus extends StatelessWidget {
  RepoStatus(this.repoCubit, {super.key});

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _Activity(repoCubit),
          _Progress(repoCubit),
        ],
      );
}

/// Widget that builds itself whenever the sync progress of the repository changes.
class RepoProgressBuilder extends StatefulWidget {
  final RepoCubit repoCubit;
  final Widget Function(BuildContext, Progress) builder;

  RepoProgressBuilder(
      {required this.repoCubit, required this.builder, super.key});

  @override
  State<RepoProgressBuilder> createState() => _RepoProgressBuilderState();
}

class _RepoProgressBuilderState extends State<RepoProgressBuilder> {
  late final Stream<Progress> stream = widget.repoCubit.syncProgressStream;

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: stream,
        builder: (context, snapshot) =>
            widget.builder(context, snapshot.data ?? Progress(0, 1)),
      );
}

class _Progress extends StatelessWidget {
  _Progress(this.repoCubit);

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => RepoProgressBuilder(
        repoCubit: repoCubit,
        builder: (context, progress) => progress.isComplete
            ? _buildCompleteIcon()
            : _buildIndicator(progress.fraction),
      );

  Widget _buildIndicator(double fraction) => Container(
        width: _iconSize,
        height: _iconSize,
        padding: EdgeInsets.all(_iconPadding),
        child: CircularProgressIndicator(
          value: fraction,
          color: _color,
          strokeWidth: 2.0,
        ),
      );

  Widget _buildCompleteIcon() => Container(
        decoration: ShapeDecoration(
          color: Colors.lightGreen,
          shape: CircleBorder(),
        ),
        padding: EdgeInsets.all(_iconPadding),
        child: Icon(
          Icons.done,
          color: Colors.white,
          size: _iconSize - 2 * _iconPadding,
        ),
      );
}

class _Activity extends StatefulWidget {
  _Activity(this.repoCubit);

  final RepoCubit repoCubit;

  @override
  State<_Activity> createState() => _ActivityState();
}

class _ActivityState extends State<_Activity> with AppLogger {
  late StateMonitorCubit? monitorCubit = widget.repoCubit.stateMonitor
      ?.let((monitor) => StateMonitorCubit(monitor));

  @override
  void dispose() {
    super.dispose();
    unawaited(monitorCubit?.close());
  }

  @override
  Widget build(BuildContext context) {
    final monitorCubit = this.monitorCubit;

    if (monitorCubit == null) {
      return SizedBox.shrink();
    }

    return BlocBuilder<StateMonitorCubit, StateMonitorNode?>(
      bloc: monitorCubit,
      builder: _buildIndicator,
    );
  }

  Widget _buildIndicator(BuildContext context, StateMonitorNode? node) {
    final index = node?.parseDoubleValue('index requests inflight') ?? 0.0;
    final block = node?.parseDoubleValue('block requests inflight') ?? 0.0;

    if (index > 0.0 || block > 0.0) {
      return Icon(
        Icons.sync,
        size: _iconSize + 2 * _iconPadding,
        color: _color,
      );
    } else {
      return SizedBox.square(dimension: 24.0);
    }
  }
}

extension _RepoCubitExtension on RepoCubit {
  Stream<Progress> get syncProgressStream =>
      events.startWith(null).asyncMapSample((_) => syncProgress);
}

// TODO: Add this to the plugin
extension _StateMonitorNodeExtension on StateMonitorNode {
  double? parseDoubleValue(String name) =>
      values[name]?.let((s) => double.tryParse(s));
}
