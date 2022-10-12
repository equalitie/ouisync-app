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
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import '../models/repo_entry.dart';
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
                SettingsSection(title: Text(S.current.titleNetwork), tiles: [
                  _buildConnectivityTypeTile(context),
                  // TODO:
                  SettingsTile.switchTile(
                    initialValue: false,
                    onToggle: (value) {},
                    title: Text('Enable UPnP'),
                    leading: Icon(Icons.router),
                    enabled: false,
                  ),
                  SettingsTile.switchTile(
                    initialValue: false,
                    onToggle: (value) {},
                    title: Text('Enable Local Discovery'),
                    leading: Icon(Icons.broadcast_on_personal),
                    enabled: false,
                  ),
                  _buildSyncOnMobileSwitch(context),
                  ..._buildConnectivityInfoTiles(context),
                  _buildPeerListTile(context),
                ]),
                SettingsSection(
                  title: Text('About'), // TODO: localize
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

//--------------------------------------------------------------------------------------------------

class SettingsPageOld extends StatefulWidget {
  const SettingsPageOld({
    required this.reposCubit,
    required this.onShareRepository,
    required this.panicCounter,
  });

  final ReposCubit reposCubit;
  final void Function(RepoCubit) onShareRepository;
  final StateMonitorIntValue panicCounter;

  @override
  State<SettingsPageOld> createState() =>
      _SettingsPageOldState(reposCubit, panicCounter);
}

class _SettingsPageOldState extends State<SettingsPageOld>
    with OuiSyncAppLogger {
  final ReposCubit _repos;
  final StateMonitorIntValue _panicCounter;

  String? _connectionType;
  String? _externalIP;
  String? _localIPv4;
  String? _localIPv6;
  String? _tcpListenerEndpointV4;
  String? _tcpListenerEndpointV6;
  String? _quicListenerEndpointV4;
  String? _quicListenerEndpointV6;

  Color? _titlesColor = Colors.black;

  _SettingsPageOldState(this._repos, this._panicCounter);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _titlesColor = Theme.of(context).colorScheme.secondary;

    return _repos.builder((repos) => ListView(
          // The badge over the version number is shown outside of the row boundary, so we
          // need to set clipBehaior to Clip.none.
          clipBehavior: Clip.none,
          children: [
            _buildRepositoriesSection(repos.currentRepo),
            _divider(),
            Fields.idLabel(
              S.current.titleNetwork,
              fontSize: Dimensions.fontAverage,
              fontWeight: FontWeight.normal,
              color: _titlesColor!,
            ),
            _buildCurrentRepoDhtSwitch(repos.currentRepo),
            _divider(),
            _buildLogsSection(),
          ],
        ));
  }

  Widget _buildCurrentRepoDhtSwitch(RepoEntry? repo) {
    if (repo is! OpenRepoEntry) {
      return SizedBox.shrink();
    }

    return repo.cubit.builder((repo) => LabeledSwitch(
          label: S.current.labelBitTorrentDHT,
          padding: const EdgeInsets.all(0.0),
          value: repo.isDhtEnabled,
          onChanged: (bool enable) {
            if (enable) {
              repo.enableDht();
            } else {
              repo.disableDht();
            }
          },
        ));
  }

  static Widget _divider() => const Divider(height: 20.0, thickness: 1.0);

  Widget _buildRepositoriesSection(RepoEntry? currentRepo) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.idLabel(S.current.titleRepository,
              fontSize: Dimensions.fontAverage,
              fontWeight: FontWeight.normal,
              color: _titlesColor!),
          Dimensions.spacingVertical,
          Container(
            padding: Dimensions.paddingActionBox,
            decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                color: Constants.inputBackgroundColor),
            child: DropdownButton<RepoEntry?>(
              isExpanded: true,
              value: currentRepo,
              underline: const SizedBox(),
              selectedItemBuilder: (context) =>
                  repositoryNames().map<Widget>((String repoName) {
                return Padding(
                    padding: Dimensions.paddingItem,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Fields.idLabel(S.current.labelSelectRepository,
                              fontSize: Dimensions.fontMicro,
                              fontWeight: FontWeight.normal,
                              color: Constants.inputLabelForeColor)
                        ]),
                        Row(
                          children: [
                            Fields.constrainedText(repoName,
                                fontWeight: FontWeight.normal),
                          ],
                        ),
                      ],
                    ));
              }).toList(),
              items: repositories().map((RepoEntry repo) {
                return DropdownMenuItem(
                  value: repo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(repo == currentRepo ? Icons.check : null,
                          size: Dimensions.sizeIconSmall,
                          color: Theme.of(context).primaryColor),
                      Dimensions.spacingHorizontalDouble,
                      Fields.constrainedText(repo.name,
                          fontWeight: FontWeight.normal),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (repo) async {
                loggy.app('Selected repository: ${repo?.name}');
                await _repos.setCurrentByName(repo?.name);
              },
            ),
          ),
          Dimensions.spacingVertical,
          Dimensions.spacingVertical,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Fields.actionText(S.current.actionRename,
                  textFontSize: Dimensions.fontAverage,
                  icon: Icons.edit,
                  iconSize: Dimensions.sizeIconSmall, onTap: () async {
                if (currentRepo == null) {
                  return;
                }

                await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      final formKey = GlobalKey<FormState>();

                      return ActionsDialog(
                        title: S.current.messageRenameRepository,
                        body: RenameRepository(
                            context: context,
                            formKey: formKey,
                            repositoryName: currentRepo.name),
                      );
                    }).then((newName) {
                  if (newName == null || newName.isEmpty) {
                    return;
                  }
                  final oldInfo = _repos.internalRepoMetaInfo(currentRepo.name);
                  final newInfo = _repos.internalRepoMetaInfo(newName);
                  _repos.renameRepository(oldInfo, newInfo);
                });
              }),
              Fields.actionText(S.current.actionShare,
                  textFontSize: Dimensions.fontAverage,
                  icon: Icons.share,
                  iconSize: Dimensions.sizeIconSmall, onTap: () {
                if (currentRepo is! OpenRepoEntry) {
                  return;
                }

                widget.onShareRepository(currentRepo.cubit);
              }),
              Fields.actionText(S.current.actionDelete,
                  textFontSize: Dimensions.fontAverage,
                  textColor: Colors.red,
                  icon: Icons.delete,
                  iconSize: Dimensions.sizeIconSmall,
                  iconColor: Colors.red, onTap: () async {
                if (currentRepo == null) {
                  return;
                }

                final delete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                            title: Text(S.current.titleDeleteRepository),
                            content: SingleChildScrollView(
                              child: ListBody(children: [
                                Text(S.current.messageConfirmRepositoryDeletion)
                              ]),
                            ),
                            actions: [
                              TextButton(
                                child: Text(S.current.actionCloseCapital),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              DangerButton(
                                text: S.current.actionDeleteCapital,
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ]));

                if (delete ?? false) {
                  _repos.deleteRepository(currentRepo.metaInfo);
                }
              })
            ],
          ),
          Dimensions.spacingVertical,
        ]);
  }

  Iterable<String> repositoryNames() {
    return _repos.repositoryNames();
  }

  Iterable<RepoEntry> repositories() {
    return _repos.repos;
  }

  Widget _buildLogsSection() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Fields.idLabel(S.current.titleLogs,
                fontSize: Dimensions.fontAverage,
                fontWeight: FontWeight.normal,
                color: _titlesColor!),
            Padding(
                padding: Dimensions.paddingActionButton,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Fields.actionText(S.current.actionSave,
                          textFontSize: Dimensions.fontAverage,
                          icon: Icons.save,
                          iconSize: Dimensions.sizeIconSmall,
                          onTap: _saveLogs),
                      Fields.actionText(S.current.actionShare,
                          textFontSize: Dimensions.fontAverage,
                          icon: Icons.share,
                          iconSize: Dimensions.sizeIconSmall,
                          onTap: _shareLogs)
                    ])),
            _panicCounter.builder((context, panics) {
              if ((panics ?? 0) == 0) return SizedBox.shrink();
              return _warningText(context, S.current.messageLibraryPanic);
            }),
          ]);

  Future<void> _saveLogs() async {
    final tempPath = await _dumpInfo();
    final params = SaveFileDialogParams(sourceFilePath: tempPath);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareLogs() async {
    final tempPath = await _dumpInfo();
    await Share.shareFiles([tempPath], mimeTypes: ['text/plain']);
  }

  Future<String> _dumpInfo() async {
    final dir = await getTemporaryDirectory();
    final info = await PackageInfo.fromPlatform();
    final name = info.appName.toLowerCase();

    final now = DateTime.now();
    // TODO: Add time zone, at time of this writing, time zones have not yet
    // been implemented by DateFormat.
    final formatter = DateFormat('yyyy-MM-dd--HH-mm-ss');
    final path =
        buildDestinationPath(dir.path, '$name--${formatter.format(now)}.log');
    final outFile = File(path);

    final sink = outFile.openWrite();

    sink.writeln("appName: ${info.appName}");
    sink.writeln("packageName: ${info.packageName}");
    sink.writeln("version: ${info.version}");
    sink.writeln("buildNumber: ${info.buildNumber}");

    sink.writeln("_connectionType: $_connectionType");
    sink.writeln("_externalIP: $_externalIP");
    sink.writeln("_localIPv4: $_localIPv4");
    sink.writeln("_localIPv6: $_localIPv6");
    sink.writeln("_tcpListenerEndpointV4: $_tcpListenerEndpointV4");
    sink.writeln("_tcpListenerEndpointV6: $_tcpListenerEndpointV6");
    sink.writeln("_quicListenerEndpointV4: $_quicListenerEndpointV4");
    sink.writeln("_quicListenerEndpointV6: $_quicListenerEndpointV6");
    sink.writeln("\n");

    await dumpAll(sink, _repos.session.getRootStateMonitor());

    await sink.close();

    return path;
  }
}

Text _warningText(BuildContext context, String str) {
  return Text(str,
      style: TextStyle(color: Theme.of(context).colorScheme.error));
}
