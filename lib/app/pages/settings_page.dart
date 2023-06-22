import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage(
    this._cubits, {
    required this.isBiometricsAvailable,
  });

  final Cubits _cubits;
  final bool isBiometricsAvailable;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(S.current.titleSettings),
        elevation: 0.0,
      ),
      body: MultiBlocProvider(
          providers: [
            BlocProvider<PowerControl>.value(value: _cubits.powerControl),
            BlocProvider<ConnectivityInfo>(
              create: (context) {
                final cubit =
                    ConnectivityInfo(session: _cubits.repositories.session);
                unawaited(cubit.update());
                return cubit;
              },
            ),
            BlocProvider<PeerSetCubit>(
              create: (context) =>
                  PeerSetCubit(session: _cubits.repositories.session)..init(),
            ),
            BlocProvider<NatDetection>(
              create: (context) => NatDetection(),
            )
          ],
          child: BlocListener<PowerControl, PowerControlState>(
              listener: (context, state) {
                unawaited(context.read<ConnectivityInfo>().update());
              },
              child: SettingsContainer(_cubits,
                  isBiometricsAvailable: isBiometricsAvailable))));
}
