import 'package:ouisync_plugin/state_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:bloc/bloc.dart';
import '../models/repo_state.dart';
import '../utils/utils.dart';

class RepositoryProgress extends StatelessWidget {
  RepoState? _repo;
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

    return StreamBuilder<Null>(
      stream: subscription.broadcastStream,
      builder: (BuildContext ctx, AsyncSnapshot<Null> snapshot) {
        if (!monitor.refresh()) {
          return shrink();
        }

        final index_inflight_s = monitor.values['index_requests_inflight'] ?? '0';
        final block_inflight_s = monitor.values['block_requests_inflight'] ?? '0';

        final index_inflight = int.tryParse(index_inflight_s) ?? 0;
        final block_inflight = int.tryParse(block_inflight_s) ?? 0;

        if (index_inflight == 0 && block_inflight == 0) {
            return shrink();
        }

        Color? color = null;

        if (block_inflight == 0) {
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
      return SizedBox.shrink();
  }
}
