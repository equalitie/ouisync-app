import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:r_get_ip/r_get_ip.dart';
import 'package:share_plus/share_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:intl/intl.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../utils/click_counter.dart';
import '../widgets/widgets.dart';
import 'pages.dart';
import 'peer_list.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.reposCubit,
    required this.onShareRepository,
    this.dhtStatus = false,
  });

  final ReposCubit reposCubit;
  final void Function(RepoCubit) onShareRepository;
  final bool dhtStatus;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with OuiSyncAppLogger {
  String? _connectionType;
  String? _externalIP;
  String? _localIPv4;
  String? _localIPv6;
  String? _tcpListenerEndpointV4;
  String? _tcpListenerEndpointV6;
  String? _quicListenerEndpointV4;
  String? _quicListenerEndpointV6;
  String? _dhtEndpointV4;
  String? _dhtEndpointV6;

  bool _bittorrentDhtStatus = false;

  Color? _titlesColor = Colors.black;

  // Clicking on the version number three times shall show the state monitor page.
  final _versionNumberClickCounter = ClickCounter(timeoutMs: 3000);

  @override
  void initState() {
    super.initState();

    _updateLocalEndpoints();

    _bittorrentDhtStatus = widget.dhtStatus;
    loggy.app('BitTorrent DHT status: ${widget.dhtStatus}');
  }

  void _updateLocalEndpoints({ConnectivityResult? connectivityResult}) async {
    // TODO: Some of these awaits takes a while to complete, it would be better
    // to do them all individually.

    final connectivity =
        connectivityResult ?? await Connectivity().checkConnectivity();

    switch (connectivity) {
        case ConnectivityResult.wifi: _connectionType = "WiFi"; break;
        case ConnectivityResult.mobile: _connectionType = "Mobile"; break;
        case ConnectivityResult.ethernet: _connectionType = "Ethernet"; break;
        case ConnectivityResult.none: _connectionType = "None"; break;
        default: _connectionType = "???"; break;
    }

    final session = widget.reposCubit.session;

    String? tcpListenerEndpointV4 = session.tcpListenerLocalAddressV4;
    String? tcpListenerEndpointV6 = session.tcpListenerLocalAddressV6;
    String? quicListenerEndpointV4 = session.quicListenerLocalAddressV4;
    String? quicListenerEndpointV6 = session.quicListenerLocalAddressV6;

    final dhtEndpointV4 = session.dhtLocalAddressV4;
    final dhtEndpointV6 = session.dhtLocalAddressV6;

    final info = NetworkInfo();

    // This really works only when connected using WiFi.
    var localIPv4  = await info.getWifiIP();
    var localIPv6  = await info.getWifiIPv6();

    // This works also when on mobile network, but doesn't show IPv6 address if
    // IPv4 is used as primary.
    final internalIpStr = await RGetIp.internalIP;

    if (internalIpStr != null) {
        final internalIp = InternetAddress.tryParse(internalIpStr);

        if (internalIp != null) {
            if (localIPv4 == null && internalIp.type == InternetAddressType.IPv4) {
                localIPv4 = internalIpStr;
            }

            if (localIPv6 == null && internalIp.type == InternetAddressType.IPv6) {
                localIPv6 = internalIpStr;
            }
        }
    }

    setState(() {
      _externalIP = "...";
      _localIPv4 = localIPv4;
      _localIPv6 = localIPv6;
      _tcpListenerEndpointV4 = tcpListenerEndpointV4;
      _tcpListenerEndpointV6 = tcpListenerEndpointV6;
      _quicListenerEndpointV4 = quicListenerEndpointV4;
      _quicListenerEndpointV6 = quicListenerEndpointV6;
      _dhtEndpointV4 = dhtEndpointV4;
      _dhtEndpointV6 = dhtEndpointV6;
    });

    // This one takes longer, so do it separately.
    RGetIp.externalIP.then((ip) => setState(() { _externalIP = ip; }));
  }

  @override
  Widget build(BuildContext context) {
    _titlesColor = Theme.of(context).colorScheme.secondary;

    final info = PackageInfo.fromPlatform();

    return Scaffold(
        appBar: AppBar(
          title: Text(S.current.titleSettings),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: widget.reposCubit.builder((repos) => ListView(
                // The badge over the version number is shown outside of the row boundary, so we
                // need to set clipBehaior to Clip.none.
                clipBehavior: Clip.none,
                children: [
                  _buildRepositoriesSection(repos.currentRepo),
                  _divider(),
                  Fields.idLabel(S.current.titleNetwork,
                      fontSize: Dimensions.fontAverage,
                      fontWeight: FontWeight.normal,
                      color: _titlesColor!),
                  LabeledSwitch(
                    label: S.current.labelBitTorrentDHT,
                    padding: const EdgeInsets.all(0.0),
                    value: _bittorrentDhtStatus,
                    onChanged: updateDhtSetting,
                  ),
                  BlocConsumer<ConnectivityCubit, ConnectivityState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          _labeledNullableText(Strings.connectionType, _connectionType),
                          _labeledNullableText(Strings.labelExternalIP, _externalIP),
                          _labeledNullableText(Strings.labelLocalIPv4, _localIPv4),
                          _labeledNullableText(Strings.labelLocalIPv6, _localIPv6),
                          _labeledNullableText(Strings.labelTcpListenerEndpointV4, _tcpListenerEndpointV4),
                          _labeledNullableText(Strings.labelTcpListenerEndpointV6, _tcpListenerEndpointV6),
                          _labeledNullableText(Strings.labelQuicListenerEndpointV4, _quicListenerEndpointV4),
                          _labeledNullableText(Strings.labelQuicListenerEndpointV6, _quicListenerEndpointV6),
                          _labeledNullableText(Strings.labelDHTv4Endpoint, _dhtEndpointV4),
                          _labeledNullableText(Strings.labelDHTv6Endpoint, _dhtEndpointV6)
                        ]
                        .whereType<Widget>()
                        .toList()
                      );
                    },
                    listener: (context, state) {
                      if (state is ConnectivityChanged) {
                        _updateLocalEndpoints(
                            connectivityResult: state.connectivityResult);
                      }
                    }),
                  _buildConnectedPeerListRow(),
                  _divider(),
                  _buildLogsSection(),
                  _divider(),
                  _versionNumberFutureBuilder(
                      S.current.labelAppVersion, info.then((info) => info.version)),
                ],
              ))));
  }

  static Widget? _labeledNullableText(String key, String? value) {
    if (value == null) {
      return null;
    }

    return Fields.labeledText(
      label: key,
      text: value,
      labelTextAlign: TextAlign.start,
      textAlign: TextAlign.end,
      space: Dimensions.spacingHorizontal,
    );
  }

  static Widget _labeledText(String key, String value) {
    return Fields.labeledText(
      label: key,
      text: value,
      labelTextAlign: TextAlign.start,
      textAlign: TextAlign.end,
      space: Dimensions.spacingHorizontal,
    );
  }

  Widget _versionNumberFutureBuilder(String key, Future<String> value) {
    return FutureBuilder<String>(
        future: value,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          late Widget version;

          if (snapshot.hasData) {
            version = _labeledText(key, snapshot.data!);
          } else if (snapshot.hasError) {
            version = _labeledText(key, "???");
          } else {
            version = _labeledText(key, "...");
          }

          return GestureDetector(
            onTap: () {
              if (_versionNumberClickCounter.registerClick() >= 3) {
                _versionNumberClickCounter.reset();

                final session = widget.reposCubit.session;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StateMonitorPage(session)
                  )
                );
              }
            },
            child: Fields.addUpgradeBadge(version, bottom: 6, end: -10)
          );
        });
  }

  static Widget _divider() => const Divider(height: 20.0, thickness: 1.0);

  Widget _buildRepositoriesSection(RepoCubit? currentRepo) {
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
              borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
              color: Constants.inputBackgroundColor
            ),
            child: DropdownButton<RepoCubit?>(
              isExpanded: true,
              value: currentRepo,
              underline: const SizedBox(),
              selectedItemBuilder: (context) => repositoryNames().map<Widget>((String repoName) {
                return Padding(
                  padding: Dimensions.paddingItem,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Fields.idLabel(
                            S.current.labelSelectRepository,
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
              items: repositories().map((RepoCubit repo) {
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
                      Fields.constrainedText(
                        repo.name,
                        fontWeight: FontWeight.normal),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (repo) async {
                loggy.app('Selected repository: ${repo?.name}');
                await widget.reposCubit.setCurrentByName(repo?.name);
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
                    iconSize: Dimensions.sizeIconSmall,
                    onTap: () async {
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
                    final oldName = currentRepo.name;
                    widget.reposCubit.renameRepository(oldName, newName);
                  });
                }),
              Fields.actionText(S.current.actionShare,
                      textFontSize: Dimensions.fontAverage,
                      icon: Icons.share,
                      iconSize: Dimensions.sizeIconSmall,
                      onTap: () {
                if (currentRepo == null) {
                  return;
                }

                widget.onShareRepository(currentRepo);
              }),
              Fields.actionText(S.current.actionDelete,
                      textFontSize: Dimensions.fontAverage,
                      textColor: Colors.red,
                      icon: Icons.delete,
                      iconSize: Dimensions.sizeIconSmall,
                      iconColor: Colors.red,
                      onTap: () async {
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
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: Text(S.current.actionDeleteCapital),
                        style: ButtonStyle(foregroundColor: MaterialStateProperty.resolveWith((_) => Colors.red)),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ]
                  )
                );

                if (delete ?? false) {
                  widget.reposCubit.deleteRepository(currentRepo.name);
                }
              })
            ],
          ),
          Dimensions.spacingVertical,
        ]);
  }

  Iterable<String> repositoryNames() {
    return widget.reposCubit.repositoryNames();
  }

  Iterable<RepoCubit> repositories() {
    return widget.reposCubit.repos;
  }

  Widget _buildConnectedPeerListRow() {
    final peerSetCubit = BlocProvider.of<PeerSetCubit>(context);

    return BlocBuilder<PeerSetCubit, PeerSetChanged>(
      builder: (context, state) =>
        Fields.labeledButton(
          label: S.current.labelConnectedPeers,
          buttonText: state.stats(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                BlocProvider.value(
                  value: peerSetCubit,
                  child: PeerList()
                )));
          }));
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
                      onTap: _shareLogs)])),
          ]);

  Future<void> updateDhtSetting(bool enable) async {
    final current = widget.reposCubit.currentRepo;

    if (current == null) {
      return;
    }

    loggy.app('${enable ? 'Enabling' : 'Disabling'} BitTorrent DHT...');

    enable
        ? current.enableDht()
        : current.disableDht();

    final isEnabled = current.isDhtEnabled();

    setState(() {
      _bittorrentDhtStatus = isEnabled;
    });

    await Settings.setDhtEnableStatus(current.id, isEnabled);

    String dhtStatusMessage = S.current.messageBitTorrentDHTStatus(isEnabled ? 'enabled' : 'disabled');

    if (enable != isEnabled) {
      dhtStatusMessage = enable
          ? S.current.messageBitTorrentDHTEnableFailed
          : S.current.messageBitTorrentDHTDisableFailed;
    }

    loggy.app(dhtStatusMessage);
    showSnackBar(context, content: Text(dhtStatusMessage));
  }

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
    final path = buildDestinationPath(dir.path, '$name--${formatter.format(now)}.log');
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
    sink.writeln("_dhtEndpointV4: $_dhtEndpointV4");
    sink.writeln("_dhtEndpointV6: $_dhtEndpointV6");
    sink.writeln("\n");

    await dumpAll(sink, widget.reposCubit.session.getRootStateMonitor());

    await sink.close();

    return path;
  }
}
