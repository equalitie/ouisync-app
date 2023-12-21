import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(this.session, this.cubits);

  final Session session;
  final Cubits cubits;

  @override
  State<SettingsPage> createState() => _SettingsPageState(session);
}

class _SettingsPageState extends State<SettingsPage> {
  final ConnectivityInfo _connectivityInfo;
  final PeerSetCubit _peerSet;
  final _natDetection = NatDetection();

  _SettingsPageState(Session session)
      : _connectivityInfo = ConnectivityInfo(session),
        _peerSet = PeerSetCubit(session);

  @override
  @override
  void initState() {
    super.initState();

    _peerSet.init();
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
          widget.cubits,
          connectivityInfo: _connectivityInfo,
          natDetection: _natDetection,
          peerSet: _peerSet,
        ),
      );

  Future<void> _updateConnectivityInfo() async {
    await _connectivityInfo.update();

    await for (final _ in widget.cubits.powerControl.stream) {
      await _connectivityInfo.update();
    }
  }
}
