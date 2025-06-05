import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/dirs.dart';
import '../widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.session,
    required this.localeCubit,
    required this.mount,
    required this.panicCounter,
    required this.powerControl,
    required this.reposCubit,
    required this.upgradeExists,
    required this.checkForDokan,
    required this.dirs,
  });

  final Session session;
  final LocaleCubit localeCubit;
  final MountCubit mount;
  final StateMonitorIntCubit panicCounter;
  final PowerControl powerControl;
  final ReposCubit reposCubit;
  final UpgradeExistsCubit upgradeExists;
  final void Function() checkForDokan;
  final Dirs dirs;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final connectivityInfo = ConnectivityInfo(widget.session);
  late final PeerSetCubit peerSet = PeerSetCubit(widget.session);
  late final NatDetection natDetection = NatDetection(widget.session);
  final launchAtStartup = LaunchAtStartupCubit();
  StreamSubscription? _powerControlSubscription;

  @override
  void initState() {
    super.initState();
    _powerControlSubscription = widget.powerControl.stream
        .map((_) => null)
        // Update once immediately, before starting to receive the events.
        .startWith(null)
        .asyncMapSample((_) => connectivityInfo.update())
        .listen(null);
  }

  @override
  void dispose() {
    unawaited(_powerControlSubscription?.cancel());

    unawaited(connectivityInfo.close());
    unawaited(peerSet.close());
    unawaited(natDetection.close());
    unawaited(launchAtStartup.close());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DirectionalAppBar(title: Text(S.current.titleSettings)),
        body: AppSettingsContainer(
          widget.session,
          localeCubit: widget.localeCubit,
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
          dirs: widget.dirs,
        ),
      );
}
