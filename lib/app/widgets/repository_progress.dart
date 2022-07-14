import 'package:ouisync_plugin/state_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/repository_progress.dart';
import '../models/repo_state.dart';
import '../utils/utils.dart';

class RepositoryProgress extends StatelessWidget {
  // This is used to make the progress go all the way from the beginning of the circle to the end.
  // If we did not use it, then after the repository gets bigger, we start seeing a circle which
  // is almost full, but with only few pixels remaining.
  RepoState? _repo;
  StateMonitor? _monitor;
  Subscription? _subscription;

  RepositoryProgress(this._repo) : _monitor = _repo?.stateMonitor() {
    _subscription = _monitor?.subscribe()!;
  }

  @override
  void dispose() {
    _subscription?.close();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = _subscription;

    if (subscription == null) return SizedBox.shrink();

    return StreamBuilder<Null>(
      stream: subscription.broadcastStream,
      builder: (BuildContext ctx, AsyncSnapshot<Null> snapshot) {
        final monitor = _monitor!;

        if (!monitor.refresh()) {
          return SizedBox.shrink();
        }

        final index_inflight_s = monitor.values['index_requests_inflight'] ?? '0';
        final block_inflight_s = monitor.values['block_requests_inflight'] ?? '0';

        final index_inflight = int.tryParse(index_inflight_s) ?? 0;
        final block_inflight = int.tryParse(block_inflight_s) ?? 0;

        if (index_inflight == 0 && block_inflight == 0) {
            return SizedBox.shrink();
        }

        // TODO: Try to also get the number of missing blocks and if
        // `block_inflight` is != 0 then set `value` of the progress indicator.
        return ConstrainedBox(
            constraints: BoxConstraints.tight(Size.square(Dimensions.sizeIconSmall)),
            child: CircularProgressIndicator(
              backgroundColor: Constants.progressBarBackgroundColor
            )
        );
      }
    );
  }
}
