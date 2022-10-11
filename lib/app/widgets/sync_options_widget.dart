import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/power_control.dart';
import 'items/labeled_switch.dart';

/// Widget to configure whether synchronization is enabled while on a mobile network.
class SyncOptionsWidget extends StatelessWidget {
  final PowerControl powerControl;

  const SyncOptionsWidget(this.powerControl);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PowerControl, PowerControlState>(
          bloc: powerControl,
          builder: (context, state) => LabeledSwitch(
                label: "Enable sync while using mobile internet",
                padding: const EdgeInsets.all(0.0),
                value: state.syncOnMobile,
                onChanged: _onChanged,
              ));

  void _onChanged(bool enable) {
    if (enable) {
      unawaited(powerControl.enableSyncOnMobile());
    } else {
      unawaited(powerControl.disableSyncOnMobile());
    }
  }
}
