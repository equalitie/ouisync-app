import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import 'background_service_manager.dart';
import 'mount.dart';
import 'power_control.dart';
import 'repos.dart';
import 'state_monitor.dart';
import 'upgrade_exists.dart';

export 'background_service_manager.dart';
export 'connectivity_info.dart';
export 'file_progress.dart';
export 'job.dart';
export 'mount.dart';
export 'nat_detection.dart';
export 'peer_set.dart';
export 'power_control.dart';
export 'repo.dart';
export 'repos.dart';
export 'security.dart';
export 'sort_list.dart';
export 'state_monitor.dart';
export 'upgrade_exists.dart';
export 'value.dart';
export 'watch.dart';

class Cubits {
  final ReposCubit repositories;
  final PowerControl powerControl;
  final StateMonitorIntCubit panicCounter;
  final UpgradeExistsCubit upgradeExists;
  final BackgroundServiceManager backgroundServiceManager;
  final PlatformWindowManager windowManager;
  // Is not null only on operating system where mounting is supported.
  final MountCubit? mount;

  Cubits(this.repositories, this.powerControl, this.panicCounter,
      this.upgradeExists, this.backgroundServiceManager, this.windowManager)
      : mount =
            (io.Platform.isWindows) ? MountCubit(repositories.session) : null;

  Color? mainNotificationBadgeColor() {
    final upgradeExists = this.upgradeExists.state;
    final panicCount = panicCounter.state ?? 0;
    final isNetworkEnabled = powerControl.state.isNetworkEnabled ?? true;
    final showWarning = backgroundServiceManager.showWarning();
    final mountState = mount?.state;

    if (upgradeExists || panicCount > 0 || mountState is MountStateError) {
      return Constants.errorColor;
    } else if (!isNetworkEnabled || showWarning) {
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
