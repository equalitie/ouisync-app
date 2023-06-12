import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage(
      {required this.settings,
      required this.reposCubit,
      required this.powerControl,
      required this.panicCounter,
      required this.natDetection,
      required this.isBiometricsAvailable});

  final Settings settings;
  final ReposCubit reposCubit;
  final PowerControl powerControl;
  final StateMonitorIntCubit panicCounter;
  final Future<NatDetection> natDetection;
  final bool isBiometricsAvailable;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _appBar(),
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
                  panicCounter: panicCounter,
                  natDetection: natDetection,
                  isBiometricsAvailable: isBiometricsAvailable))));

  PreferredSizeWidget _appBar() =>
      PlatformValues.isDesktopDevice ? _desktopBar() : _mobileBar();

  PreferredSizeWidget _mobileBar() => AppBar(
        title: Text(PlatformValues.isMobileDevice
            ? S.current.titleSettings
            : S.current.messageOuiSyncDesktopTitle),
        elevation: 0.0,
      );

  PreferredSizeWidget _desktopBar() => AppBar(
        title: WindowTitleBarBox(
            child: Row(children: [
          Expanded(
              child: MoveWindow(
            child: Text(PlatformValues.isMobileDevice
                ? S.current.titleSettings
                : S.current.messageOuiSyncDesktopTitle),
          )),
          _windowButtons()
        ])),
        elevation: 0.0,
      );

  Widget _windowButtons() =>
      Row(children: [MinimizeWindowButton(), CloseWindowButton()]);
}
