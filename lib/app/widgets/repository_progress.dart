import 'package:ouisync_plugin/state_monitor.dart';
import 'package:flutter/material.dart';
import '../cubits/repo.dart';

class RepositoryProgress extends StatelessWidget {
  final RepoCubit? _repo;
  StateMonitor? _monitor;
  Subscription? _subscription;

  RepositoryProgress(this._repo);

  @override
  void dispose() {
    _subscription?.close();
  }

  @override
  Widget build(BuildContext context) {
    final repo = _repo;
    if (repo == null) return shrink();

    _monitor = repo.stateMonitor();
    final monitor = _monitor;
    if (monitor == null) return shrink();

    _subscription?.close();
    _subscription = monitor.subscribe();
    final subscription = _subscription;
    if (subscription == null) return shrink();

    return StreamBuilder<void>(
      stream: subscription.broadcastStream,
      builder: (BuildContext ctx, AsyncSnapshot<void> snapshot) {
        if (!monitor.refresh()) {
          return shrink();
        }

        final indexInflightS = monitor.values['index_requests_inflight'] ?? '0';
        final blockInflightS = monitor.values['block_requests_inflight'] ?? '0';

        final indexInflight = int.tryParse(indexInflightS) ?? 0;
        final blockInflight = int.tryParse(blockInflightS) ?? 0;

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
      }
    );
  }

  Widget shrink() {
      return const SizedBox.shrink();
  }
}
