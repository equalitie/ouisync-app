import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'peer_list.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.reposCubit,
    required this.powerControl,
    required this.onShareRepository,
    required this.panicCounter,
  });

  final ReposCubit reposCubit;
  final PowerControl powerControl;
  final void Function(RepoCubit) onShareRepository;
  final StateMonitorIntValue panicCounter;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(S.current.titleSettings),
        elevation: 0.0,
      ),
      body: MultiBlocProvider(
          providers: [
            BlocProvider<PowerControl>.value(value: powerControl),
            BlocProvider<ConnectivityInfo>(create: (context) {
              final cubit = ConnectivityInfo(session: reposCubit.session);
              unawaited(cubit.update());
              return cubit;
            })
          ],
          child: BlocListener<PowerControl, PowerControlState>(
            listener: (context, state) {
              unawaited(context.read<ConnectivityInfo>().update());
            },
            child: SettingsList(
              sections: [
                RepositorySection(
                  repos: reposCubit,
                  onShareRepository: onShareRepository,
                ),
                _buildNetworkSection(context),
                _buildLogsSection(context),
                SettingsSection(
                  title: Text(S.current.titleAbout),
                  tiles: [
                    CustomSettingsTile(
                      child: AppVersionTile(
                        session: reposCubit.session,
                        leading: Icon(Icons.info_outline),
                        title: Text(S.current.labelAppVersion),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )));

  AbstractSettingsSection _buildNetworkSection(BuildContext context) =>
      SettingsSection(
        title: Text(S.current.titleNetwork),
        tiles: [
          _buildConnectivityTypeTile(context),
          // TODO:
          SettingsTile.switchTile(
            initialValue: false,
            onToggle: (value) {},
            title: Text('UPnP'),
            leading: Icon(Icons.router),
            enabled: false,
          ),
          // TODO:
          SettingsTile.switchTile(
            initialValue: false,
            onToggle: (value) {},
            title: Text('Local Discovery'),
            leading: Icon(Icons.broadcast_on_personal),
            enabled: false,
          ),
          _buildSyncOnMobileSwitch(context),
          ..._buildConnectivityInfoTiles(context),
          _buildPeerListTile(context),
        ],
      );

  AbstractSettingsTile _buildConnectivityTypeTile(BuildContext context) =>
      CustomSettingsTile(
        child: BlocBuilder<PowerControl, PowerControlState>(
          builder: (context, state) => SettingsTile(
            leading: Icon(Icons.wifi),
            title: Text(Strings.connectionType),
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_connectivityTypeName(state.connectivityType)),
                if (state.networkDisabledReason != null)
                  Text('(${state.networkDisabledReason!})'),
              ],
            ),
            trailing: (state.isNetworkEnabled ?? true)
                ? null
                : Icon(Icons.warning, color: Constants.warningColor),
          ),
        ),
      );

  AbstractSettingsTile _buildSyncOnMobileSwitch(BuildContext context) =>
      CustomSettingsTile(
          child: BlocSelector<PowerControl, PowerControlState, bool>(
        selector: (state) => state.syncOnMobile,
        builder: (context, value) => SettingsTile.switchTile(
          initialValue: value,
          onToggle: (value) {
            if (value) {
              unawaited(powerControl.enableSyncOnMobile());
            } else {
              unawaited(powerControl.disableSyncOnMobile());
            }
          },
          title: Text('Sync while using mobile data'),
          leading: Icon(Icons.mobile_screen_share),
        ),
      ));

  List<AbstractSettingsTile> _buildConnectivityInfoTiles(
          BuildContext context) =>
      [
        _buildConnectivityInfoTile(
          Strings.labelTcpListenerEndpointV4,
          Icons.computer,
          (state) => state.tcpListenerV4,
        ),
        _buildConnectivityInfoTile(
          Strings.labelTcpListenerEndpointV6,
          Icons.computer,
          (state) => state.tcpListenerV6,
        ),
        _buildConnectivityInfoTile(
          Strings.labelQuicListenerEndpointV4,
          Icons.computer,
          (state) => state.quicListenerV4,
        ),
        _buildConnectivityInfoTile(
          Strings.labelQuicListenerEndpointV6,
          Icons.computer,
          (state) => state.quicListenerV6,
        ),
        _buildConnectivityInfoTile(
          Strings.labelExternalIP,
          Icons.cloud_outlined,
          (state) => state.externalIP,
        ),
        _buildConnectivityInfoTile(
          Strings.labelLocalIPv4,
          Icons.lan_outlined,
          (state) => state.localIPv4,
        ),
        _buildConnectivityInfoTile(
          Strings.labelLocalIPv6,
          Icons.lan_outlined,
          (state) => state.localIPv6,
        ),
      ];

  AbstractSettingsTile _buildConnectivityInfoTile(
    String title,
    IconData icon,
    String Function(ConnectivityInfoState) selector,
  ) =>
      CustomSettingsTile(
          child: BlocSelector<ConnectivityInfo, ConnectivityInfoState, String>(
              selector: selector,
              builder: (context, value) {
                if (value.isNotEmpty) {
                  return SettingsTile(
                    leading: Icon(icon),
                    title: Text(title),
                    value: Text(value),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }));

  AbstractSettingsTile _buildPeerListTile(BuildContext context) =>
      CustomSettingsTile(
        child: BlocBuilder<PeerSetCubit, PeerSetChanged>(
          builder: (context, state) => SettingsTile.navigation(
              leading: Icon(Icons.people),
              trailing: Icon(_navigationIcon),
              title: Text(S.current.labelConnectedPeers),
              value: Text(state.stats()),
              onPressed: (context) {
                final peerSetCubit = context.read<PeerSetCubit>();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                              value: peerSetCubit,
                              child: PeerList(),
                            )));
              }),
        ),
      );

  AbstractSettingsSection _buildLogsSection(BuildContext context) =>
      SettingsSection(
        title: Text(S.current.titleLogs),
        tiles: [
          SettingsTile.navigation(
            title: Text(S.current.actionSave),
            leading: Icon(Icons.save),
            trailing: Icon(_navigationIcon),
            onPressed: _saveLogs,
          ),
          SettingsTile.navigation(
            title: Text(S.current.actionShare),
            leading: Icon(Icons.share),
            trailing: Icon(_navigationIcon),
            onPressed: _shareLogs,
          ),
          CustomSettingsTile(child: panicCounter.builder((context, count) {
            if ((count ?? 0) > 0) {
              final color = Theme.of(context).colorScheme.error;
              return SettingsTile(
                title: Text(
                  S.current.messageLibraryPanic,
                  style: TextStyle(color: color),
                ),
                leading: Icon(Icons.error, color: color),
              );
            } else {
              return SizedBox.shrink();
            }
          })),
        ],
      );

  Future<void> _saveLogs(BuildContext context) async {
    final tempPath = await _dumpInfo(context);
    final params = SaveFileDialogParams(sourceFilePath: tempPath);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareLogs(BuildContext context) async {
    final tempPath = await _dumpInfo(context);
    await Share.shareFiles([tempPath], mimeTypes: ['text/plain']);
  }

  Future<String> _dumpInfo(BuildContext context) async {
    final dir = await getTemporaryDirectory();
    final info = await PackageInfo.fromPlatform();
    final name = info.appName.toLowerCase();

    final connType = context.read<PowerControl>().state.connectivityType;
    final connInfo = context.read<ConnectivityInfo>().state;

    // TODO: Add time zone, at time of this writing, time zones have not yet
    // been implemented by DateFormat.
    final formatter = DateFormat('yyyy-MM-dd--HH-mm-ss');
    final timestamp = formatter.format(DateTime.now());
    final path = buildDestinationPath(dir.path, '$name--$timestamp.log');
    final outFile = File(path);

    final sink = outFile.openWrite();

    try {
      sink.writeln("appName: ${info.appName}");
      sink.writeln("packageName: ${info.packageName}");
      sink.writeln("version: ${info.version}");
      sink.writeln("buildNumber: ${info.buildNumber}");

      sink.writeln("connectionType: $connType");
      sink.writeln("externalIP: ${connInfo.externalIP}");
      sink.writeln("localIPv4: ${connInfo.localIPv4}");
      sink.writeln("localIPv6: ${connInfo.localIPv6}");
      sink.writeln("tcpListenerV4:  ${connInfo.tcpListenerV4}");
      sink.writeln("tcpListenerV6:  ${connInfo.tcpListenerV6}");
      sink.writeln("quicListenerV4: ${connInfo.quicListenerV4}");
      sink.writeln("quicListenerV6: ${connInfo.quicListenerV6}");
      sink.writeln("\n");

      await dumpAll(sink, reposCubit.session.getRootStateMonitor());
    } finally {
      await sink.close();
    }

    return path;
  }
}

const _navigationIcon = Icons.navigate_next;

String _connectivityTypeName(ConnectivityResult result) {
  switch (result) {
    case ConnectivityResult.bluetooth:
      return "Bluetooth";
    case ConnectivityResult.wifi:
      return "WiFi";
    case ConnectivityResult.mobile:
      return "Mobile";
    case ConnectivityResult.ethernet:
      return "Ethernet";
    case ConnectivityResult.none:
      return "None";
  }
}
