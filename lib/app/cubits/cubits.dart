import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/utils.dart';
import 'mount.dart';
import 'power_control.dart';
import 'state_monitor.dart';
import 'upgrade_exists.dart';

export 'connectivity_info.dart';
export 'entry_bottom_sheet.dart';
export 'file_progress.dart';
export 'job.dart';
export 'mount.dart';
export 'nat_detection.dart';
export 'navigation.dart';
export 'peer_set.dart';
export 'power_control.dart';
export 'repo.dart';
export 'repos.dart';
export 'sort_list.dart';
export 'state_monitor.dart';
export 'upgrade_exists.dart';
export 'value.dart';
export 'watch.dart';

class Cubits {
  final PowerControl powerControl;
  final StateMonitorIntCubit panicCounter;
  final UpgradeExistsCubit upgradeExists;
  final MountCubit mount;

  Cubits({
    required this.powerControl,
    required this.panicCounter,
    required this.upgradeExists,
    required this.mount,
  });

  Color? mainNotificationBadgeColor() {
    final upgradeExists = this.upgradeExists.state;
    final panicCount = panicCounter.state ?? 0;
    final isNetworkEnabled = powerControl.state.isNetworkEnabled ?? true;
    final mountState = mount.state;

    if (upgradeExists || panicCount > 0 || mountState is MountStateError) {
      return Constants.errorColor;
    } else if (!isNetworkEnabled) {
      return Constants.warningColor;
    } else {
      return null;
    }
  }
}

Widget multiBlocBuilder(
  List<StateStreamable<Object?>> blocs,
  Widget Function() innerBuilder,
) {
  var builder = (a, b) => innerBuilder();

  for (var bloc in blocs) {
    final newBuilder = ((builder) => (a, b) {
          return BlocBuilder<StateStreamable<Object?>, Object?>(
            bloc: bloc,
            builder: builder,
          );
        })(builder);

    builder = newBuilder;
  }

  return builder(Object(), null);
}
