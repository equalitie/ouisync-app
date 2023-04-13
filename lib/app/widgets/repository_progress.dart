import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/state_monitor.dart';

import '../cubits/cubits.dart';

class RepositoryProgress extends StatelessWidget {
  final StateMonitorCubit? _monitor;

  RepositoryProgress(RepoCubit? repo)
      : _monitor = repo != null ? StateMonitorCubit(repo.stateMonitor) : null;

  @override
  Widget build(BuildContext context) {
    final monitor = _monitor;

    if (monitor == null) {
      return shrink();
    }

    return BlocBuilder<StateMonitorCubit, StateMonitorNode?>(
        bloc: monitor,
        builder: (context, node) {
          if (node == null) return shrink();

          final indexInflight =
              node.parseIntValue('index requests inflight') ?? 0;
          final blockInflight =
              node.parseIntValue('block requests inflight') ?? 0;

          if (indexInflight == 0 && blockInflight == 0) {
            return shrink();
          }

          Color? color;

          if (blockInflight == 0) {
            color = Colors.grey.shade400;
          }

          // TODO: Try to also get the number of missing blocks and if
          // `block_inflight` is != 0 then set `value` of the progress indicator.
          return LinearProgressIndicator(
            color: color,
            backgroundColor: Colors.white,
          );
        });
  }

  Widget shrink() {
    return const SizedBox.shrink();
  }
}
