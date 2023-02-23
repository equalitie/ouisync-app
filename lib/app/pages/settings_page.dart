import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.settings,
    required this.reposCubit,
    required this.isBiometricsAvailable,
    required this.powerControl,
    required this.onShareRepository,
    required this.panicCounter,
    required this.natDetection,
  });

  final Settings settings;
  final ReposCubit reposCubit;
  final bool isBiometricsAvailable;
  final PowerControl powerControl;
  final void Function(RepoCubit) onShareRepository;
  final StateMonitorIntCubit panicCounter;
  final Future<NatDetection> natDetection;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(PlatformValues.isMobileDevice
            ? S.current.titleSettings
            : S.current.messageOuiSyncDesktopTitle),
        elevation: 0.0,
      ),
      body: MultiBlocProvider(
          providers: [
            BlocProvider<PowerControl>.value(value: powerControl),
            BlocProvider<ConnectivityInfo>(
              create: (context) {
                final cubit = ConnectivityInfo(session: reposCubit.session);
                unawaited(cubit.update());
                return cubit;
              },
            ),
            BlocProvider<PeerSetCubit>(
              create: (context) =>
                  PeerSetCubit(session: reposCubit.session)..init(),
            ),
          ],
          child: BlocListener<PowerControl, PowerControlState>(
            listener: (context, state) {
              unawaited(context.read<ConnectivityInfo>().update());
            },
            child: SettingsContainer(
              reposCubit: reposCubit,
              settings: settings,
              isBiometricsAvailable: isBiometricsAvailable,
              panicCounter: panicCounter,
              natDetection: natDetection,
              onShareRepository: onShareRepository,
            ),
          )));
}
