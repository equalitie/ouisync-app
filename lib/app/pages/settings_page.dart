import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/platform/platform_widget.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
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
  final StateMonitorIntValue panicCounter;
  final Future<NatDetection> natDetection;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(S.current.titleSettings),
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
            child: SettingsPlatformBody(
              reposCubit: reposCubit,
              settings: settings,
              isBiometricsAvailable: isBiometricsAvailable,
              panicCounter: panicCounter,
              natDetection: natDetection,
              onShareRepository: onShareRepository,
            ),
          )));
}

class SettingsPlatformBody extends PlatformWidget<Widget, Widget> {
  SettingsPlatformBody(
      {required this.reposCubit,
      required this.settings,
      required this.isBiometricsAvailable,
      required this.panicCounter,
      required this.natDetection,
      required this.onShareRepository});

  final ReposCubit reposCubit;
  final Settings settings;
  final bool isBiometricsAvailable;
  final StateMonitorIntValue panicCounter;
  final Future<NatDetection> natDetection;

  final void Function(RepoCubit) onShareRepository;

  @override
  Widget buildDesktopWidget(BuildContext context) {
    // TODO: implement buildDesktopWidget
    throw UnimplementedError();
  }

  @override
  Widget buildMobileWidget(BuildContext context) =>
      SettingsList(platform: PlatformUtils.detectPlatform(context), sections: [
        RepositorySectionMobile(
          repos: reposCubit,
          isBiometricsAvailable: isBiometricsAvailable,
          onShareRepository: onShareRepository,
        ),
        NetworkSectionMobile(natDetection),
        LogsSectionMobile(
            settings: settings,
            repos: reposCubit,
            panicCounter: panicCounter,
            natDetection: natDetection),
        AboutSectionMobile(repos: reposCubit)
      ]);
}
