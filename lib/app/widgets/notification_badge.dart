import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/utils/constants.dart';

import '../cubits/mount.dart';
import '../cubits/power_control.dart';
import '../cubits/state_monitor.dart';
import '../cubits/upgrade_exists.dart';
import '../utils/fields.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    required this.child,
    required this.mount,
    required this.panicCounter,
    required this.powerControl,
    required this.upgradeExists,
    this.moveDownwards = 0,
    this.moveRight = 0,
    super.key,
  });

  final Widget child;
  final double moveDownwards;
  final double moveRight;

  final MountCubit mount;
  final StateMonitorIntCubit panicCounter;
  final PowerControl powerControl;
  final UpgradeExistsCubit upgradeExists;

  @override
  Widget build(BuildContext context) => BlocBuilder<MountCubit, MountState>(
        bloc: mount,
        builder: (context, mountState) =>
            BlocBuilder<StateMonitorIntCubit, int?>(
          bloc: panicCounter,
          builder: (context, panicCounterState) =>
              BlocBuilder<PowerControl, PowerControlState>(
            bloc: powerControl,
            builder: (context, powerControlState) =>
                BlocBuilder<UpgradeExistsCubit, bool>(
              bloc: upgradeExists,
              builder: (context, upgradeExistsState) {
                Color? color;

                if (upgradeExistsState) {
                  color = Constants.errorColor;
                } else if ((panicCounterState ?? 0) > 0) {
                  color = Constants.errorColor;
                } else if (mountState is MountStateError) {
                  color = Constants.errorColor;
                } else if (!(powerControlState.isInternetConnectivityEnabled ??
                    true)) {
                  color = Constants.warningColor;
                }

                if (color != null) {
                  return Fields.addBadge(
                    child,
                    color: color,
                    moveDownwards: moveDownwards,
                    moveRight: moveRight,
                  );
                } else {
                  return child;
                }
              },
            ),
          ),
        ),
      );
}
