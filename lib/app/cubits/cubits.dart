export 'connectivity_info.dart';
export 'job.dart';
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repos.dart';
import 'power_control.dart';
import 'state_monitor.dart';
import 'upgrade_exists.dart';

class Cubits {
  final ReposCubit repositories;
  final PowerControl powerControl;
  final StateMonitorIntCubit panicCounter;
  final UpgradeExistsCubit upgradeExists;

  Cubits(this.repositories, this.powerControl, this.panicCounter,
      this.upgradeExists);
}

Widget multiBlocBuilder(
    List<StateStreamable<Object?>> blocs, Widget innerBuilder()) {
  var builder = (a, b) => innerBuilder();

  for (var bloc in blocs) {
    final new_builder = ((builder) => (a, b) {
          return BlocBuilder<StateStreamable<Object?>, Object?>(
            bloc: bloc,
            builder: builder,
          );
        })(builder);

    builder = new_builder;
  }

  return builder(Object(), null);
}
