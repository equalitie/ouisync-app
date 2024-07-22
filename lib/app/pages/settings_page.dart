import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../cubits/launch_at_startup.dart';
import '../widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.session,
    required this.mount,
    required this.panicCounter,
    required this.powerControl,
    required this.reposCubit,
    required this.upgradeExists,
    required this.checkForDokan,
  });

  final Session session;
  final MountCubit mount;
  final StateMonitorIntCubit panicCounter;
  final PowerControl powerControl;
  final ReposCubit reposCubit;
  final UpgradeExistsCubit upgradeExists;
  final void Function() checkForDokan;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final connectivityInfo = ConnectivityInfo(widget.session);
  late final PeerSetCubit peerSet = PeerSetCubit(widget.session);
  late final NatDetection natDetection = NatDetection(widget.session);
  final launchAtStartup = LaunchAtStartupCubit();

  @override
  void initState() {
    super.initState();

    peerSet.init();
    unawaited(_updateConnectivityInfo());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.titleSettings),
          elevation: 0.0,
        ),
        body: AppSettingsContainer(
          widget.session,
          mount: widget.mount,
          panicCounter: widget.panicCounter,
          powerControl: widget.powerControl,
          reposCubit: widget.reposCubit,
          connectivityInfo: connectivityInfo,
          natDetection: natDetection,
          peerSet: peerSet,
          checkForDokan: widget.checkForDokan,
          launchAtStartup: launchAtStartup,
          upgradeExists: widget.upgradeExists,
        ),
      );

  Future<void> _updateConnectivityInfo() async {
    await connectivityInfo.update();

    await for (final _ in widget.powerControl.stream) {
      await connectivityInfo.update();
    }
  }
}
