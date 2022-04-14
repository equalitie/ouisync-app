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

import '../../generated/l10n.dart';
import '../cubit/cubits.dart';
import '../models/main_state.dart';
import '../models/repo_state.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'pages.dart';
import 'peer_list.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.mainState,
    required this.repositoriesCubit,
    required this.onRepositorySelect,
    required this.onShareRepository,
    required this.title,
    this.dhtStatus = false,
  });

  final MainState mainState;
  final RepositoriesCubit repositoriesCubit;
  final RepositoryCallback onRepositorySelect;
  final void Function() onShareRepository;
  final String title;
  final bool dhtStatus;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with OuiSyncAppLogger {
  RepoState? _currentRepo;

  String? _listenerEndpoint;
  String? _dhtEndpointV4;
  String? _dhtEndpointV6;

  bool _bittorrentDhtStatus = false;

  Color? _titlesColor = Colors.black;

  @override
  void initState() {
    super.initState();

    _updateLocalEndpoints();

    _bittorrentDhtStatus = widget.dhtStatus;
    loggy.app('BitTorrent DHT status: ${widget.dhtStatus}');

    setState(() {
      _currentRepo = widget.mainState.current;
    });
  }

  void _updateLocalEndpoints({ConnectivityResult? connectivityResult}) async {
    final connectivity =
        connectivityResult ?? await Connectivity().checkConnectivity();

    final isConnected = [
      ConnectivityResult.ethernet,
      ConnectivityResult.mobile,
      ConnectivityResult.wifi
    ].contains(connectivity);

    final session = widget.repositoriesCubit.session;

    String? listenerEndpoint = session.listenerLocalAddress;
    var dhtEndpointV4 = session.dhtLocalAddressV4;
    var dhtEndpointV6 = session.dhtLocalAddressV6;

    if (isConnected) {
      loggy.app('Network unavailable');
      listenerEndpoint = await _replaceIfUndeterminedIP(listenerEndpoint);
      dhtEndpointV4 = await _replaceIfUndeterminedIP(dhtEndpointV4);
      dhtEndpointV6 = await _replaceIfUndeterminedIP(dhtEndpointV6);
    }

    setState(() {
      _listenerEndpoint = listenerEndpoint;
      _dhtEndpointV4 = dhtEndpointV4;
      _dhtEndpointV6 = dhtEndpointV6;
    });
  }

  Future<String?> _replaceIfUndeterminedIP(String? endpoint) async {
    if (endpoint == null) {
      return null;
    }

    final nullableInternal = await RGetIp.internalIP;

    if (nullableInternal == null) {
      return endpoint;
    }

    InternetAddress? internal = InternetAddress.tryParse(nullableInternal);

    if (internal == null) {
      return endpoint;
    }

    var replace = false;

    if (endpoint.contains(Strings.emptyIPv4)) {
      if (internal.type != InternetAddressType.IPv4) {
        return null;
      }
      replace = true;
    }

    if (endpoint.contains(Strings.undeterminedIPv6)) {
      if (internal.type != InternetAddressType.IPv6) {
        return null;
      }
      replace = true;
    }

    if (replace) {
      final indexFirstSemicolon = endpoint.indexOf(':');
      final indexLastSemicolon = endpoint.lastIndexOf(':');

      final protocol = endpoint.substring(0, indexFirstSemicolon);
      final port = endpoint.substring(indexLastSemicolon + 1);

      return '$protocol:${internal.address}:$port';
    }

    return endpoint;
  }

  @override
  Widget build(BuildContext context) {
    _titlesColor = Theme.of(context).colorScheme.secondary;

    final info = PackageInfo.fromPlatform();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRepositoriesSection(),
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
                        _labeledNullableText(Strings.labelListenerEndpoint, _listenerEndpoint),
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
                _futureLabeledText(
                    S.current.labelAppVersion, info.then((info) => info.version)),
              ],
            )));
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

  static _futureLabeledText(String key, Future<String> value) {
    return FutureBuilder<String>(
        future: value,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return _labeledText(key, snapshot.data!);
          } else if (snapshot.hasError) {
            return _labeledText(key, "???");
          } else {
            return _labeledText(key, "...");
          }
        });
  }

  static Widget _divider() => const Divider(height: 20.0, thickness: 1.0);

  Widget _buildRepositoriesSection() {
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              color: Color.fromRGBO(33, 33, 33, 0.07999999821186066),
            ),
            child: Container(
              padding: Dimensions.paddingActionBox,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radiusMicro)),
                border: Border.all(
                    color: Colors.black45,
                    width: 1.0,
                    style: BorderStyle.solid),
                color: Colors.grey.shade300,
              ),
              child: BlocListener(
                bloc: widget.repositoriesCubit,
                listener: (context, state) {
                  if (state is RepositoryPickerSelection) {
                    setState(() {
                      _currentRepo = widget.mainState.current!;
                    });
                  }
                },
                child: DropdownButton<RepoState?>(
                  isExpanded: true,
                  value: _currentRepo,
                  underline: SizedBox(),
                  items: widget.mainState.repos.map((RepoState repo) {
                    return DropdownMenuItem(
                      value: repo,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Fields.idLabel(S.current.labelSelectRepository,
                              textAlign: TextAlign.start,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade600),
                          Dimensions.spacingVerticalHalf,
                          Row(
                            children: [
                              Fields.constrainedText(repo.name,
                                  fontWeight: FontWeight.normal),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (repo) async {
                    loggy.app('Selected repository: ${repo?.name}');
                    setState(() {
                      _currentRepo = repo;
                    });
                    widget.mainState.setCurrent(_currentRepo!.name);
                  },
                ),
              ),
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
                  if (_currentRepo == null) {
                    return;
                  }

                  await showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        final formKey = GlobalKey<FormState>();

                        return ActionsDialog(
                          title: S.current.messageRenameRepository,
                          body: RenameRepository(
                              context: context,
                              formKey: formKey,
                              repositoryName: widget.mainState.current!.name),
                        );
                      }).then((newName) {
                    if (newName?.isNotEmpty ?? false) {
                      final oldName = _currentRepo!.name;
                      setState(() {
                        _currentRepo = null;
                      });

                      widget.repositoriesCubit
                          .renameRepository(oldName, newName!);
                    }
                  });
                }),
              Fields.actionText(S.current.actionShare,
                      textFontSize: Dimensions.fontAverage,
                      icon: Icons.share,
                      iconSize: Dimensions.sizeIconSmall,
                      onTap: () {
                if (_currentRepo == null) {
                  return;
                }

                widget.onShareRepository.call();
              }),
              Fields.actionText(S.current.actionDelete,
                      textFontSize: Dimensions.fontAverage,
                      textColor: Colors.red,
                      icon: Icons.delete,
                      iconSize: Dimensions.sizeIconSmall,
                      iconColor: Colors.red,
                      onTap: () async {
                if (_currentRepo == null) {
                  return;
                }
                await showDialog<bool>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (context) {
                      return AlertDialog(
                        title: Text(S.current.titleDeleteRepository),
                        content: SingleChildScrollView(
                          child: ListBody(children: [
                            Text(S.current.messageConfirmRepositoryDeletion)
                          ]),
                        ),
                        actions: [
                          TextButton(
                              child: Text(S.current.actionDeleteCapital),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              }),
                          TextButton(
                            child: Text(S.current.actionCloseCapital),
                            onPressed: () => Navigator.of(context).pop(false),
                          )
                        ],
                      );
                    }).then((delete) {
                  if (delete ?? false) {
                    final repositoryName = _currentRepo!.name;
                    setState(() {
                      _currentRepo = null;
                      _bittorrentDhtStatus = false;
                    });

                    widget.repositoriesCubit.deleteRepository(repositoryName);
                  }
                });
              })
            ],
          ),
          Dimensions.spacingVertical,
        ]);
  }

  Widget _buildConnectedPeerListRow() {
    final peerSetCubit = BlocProvider.of<PeerSetCubit>(context);

    return BlocConsumer<PeerSetCubit, PeerSetChanged>(
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
          })
      ,
      listener: (context, state) {
      });
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
    final current = widget.mainState.current;

    if (current == null) {
      return;
    }

    loggy.app('${enable ? 'Enabling' : 'Disabling'} BitTorrent DHT...');

    enable
        ? await current.repo.enableDht()
        : await current.repo.disableDht();

    final isEnabled = await current.repo.isDhtEnabled();
    setState(() {
      _bittorrentDhtStatus = isEnabled;
    });

    RepositoryHelper.updateBitTorrentDHTForRepoStatus(current.name, isEnabled);

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
    final tempPath = await _dumpLogs();
    final params = SaveFileDialogParams(sourceFilePath: tempPath);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareLogs() async {
    final tempPath = await _dumpLogs();
    await Share.shareFiles([tempPath], mimeTypes: ['text/plain']);
  }

  Future<String> _dumpLogs() async {
    final dir = await getTemporaryDirectory();
    final info = await PackageInfo.fromPlatform();
    final name = info.appName.toLowerCase();
    final path = buildDestinationPath(dir.path, '$name.log');

    await dumpLogs(path);

    return path;
  }
}
