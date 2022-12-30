import 'package:flutter/material.dart';

import '../cubits/cubits.dart';

class RepositoryProgress extends StatelessWidget {
  final StateMonitor? _monitor;

  RepositoryProgress(RepoCubit? repo) : _monitor = repo?.stateMonitor();

  @override
  Widget build(BuildContext context) {
    final monitor = _monitor;
    if (monitor == null) return shrink();

    return monitor.builder((context, monitor) {
      if (monitor == null) {
        return shrink();
      }

      final indexInflight =
          monitor.parseIntValue('index_requests_inflight') ?? 0;
      final blockInflight =
          monitor.parseIntValue('block_requests_inflight') ?? 0;

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
