import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/utils/constants.dart';

import '../cubits/mount.dart';
import '../cubits/power_control.dart';
import '../cubits/state_monitor.dart';
import '../cubits/upgrade_exists.dart';
import '../cubits/error.dart' show ErrorCubit, ErrorCubitState;
import '../utils/fields.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    required this.child,
    required this.mount,
    required this.errorCubit,
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
  final ErrorCubit errorCubit;
  final PowerControl powerControl;
  final UpgradeExistsCubit upgradeExists;

  @override
  Widget build(BuildContext context) => BlocBuilder<MountCubit, MountState>(
    bloc: mount,
    builder: (context, mountState) => BlocBuilder<ErrorCubit, ErrorCubitState>(
      bloc: errorCubit,
      builder: (context, errorCubitState) =>
          BlocBuilder<PowerControl, PowerControlState>(
            bloc: powerControl,
            builder: (context, powerControlState) =>
                BlocBuilder<UpgradeExistsCubit, bool>(
                  bloc: upgradeExists,
                  builder: (context, upgradeExistsState) {
                    Color? color;

                    if (upgradeExistsState) {
                      color = Constants.errorColor;
                    } else if (errorCubitState.errorHappened) {
                      color = Constants.errorColor;
                    } else if (mountState is MountStateFailure) {
                      color = Constants.errorColor;
                    } else if (!(powerControlState
                            .isInternetConnectivityEnabled ??
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
