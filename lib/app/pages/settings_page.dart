import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:io/io.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_get_ip/r_get_ip.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path; 

import '../../generated/l10n.dart';
import '../cubit/cubits.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef MoveFilesCallback = Future<void> Function({String from, String to});

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.repositoriesCubit,
    required this.onRepositorySelect,
    required this.onShareRepository,
    required this.resetReposCallback,
    required this.title,
    this.dhtStatus = false,
  });

  final RepositoriesCubit repositoriesCubit;
  final RepositoryCallback onRepositorySelect;
  final void Function() onShareRepository;
  final ResetRepositoriesCallback resetReposCallback;
  final String title;
  final bool dhtStatus;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with OuiSyncAppLogger {
  RepositoriesService _repositoriesSession = RepositoriesService();

  NamedRepo? _persistedRepository;

  String? _listenerEndpoint;
  String? _dhtEndpointV4;
  String? _dhtEndpointV6;

  bool _bittorrentDhtStatus = false;

  String? _storagePath;
  String? _newStoragePath;
  String? _storageType;
  bool _movingToExternalStorage = false;

  Color? _titlesColor = Colors.black;

  @override
  void initState() {
    super.initState();

    _initStorageValues();

    _updateLocalEndpoints();

    _bittorrentDhtStatus = widget.dhtStatus;
    loggy.app('BitTorrent DHT status: ${widget.dhtStatus}');

    setState(() {
      _persistedRepository = _repositoriesSession.current;
    });
  }

  void _initStorageValues() async {
    _storagePath = await Constants.reposPath;
    _storageType = await Constants.storageType;

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
          child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  }, listener: (context, state) {
                    if (state is ConnectivityChanged) {
                      _updateLocalEndpoints(
                          connectivityResult: state.connectivityResult);
                    }
                  }),
                  _divider(),
                  _buildStorageSection(),
                  _divider(),
                  _buildLogsSection(),
                  _divider(),
                  _futureLabeledText(
                      S.current.labelAppVersion, info.then((info) => info.version)),
                ],
              )
            )
          )
    );
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
                      _persistedRepository = _repositoriesSession.current!;
                    });
                  }
                },
                child: DropdownButton<NamedRepo?>(
                  isExpanded: true,
                  value: _persistedRepository,
                  underline: SizedBox(),
                  items: _repositoriesSession.repos.map((NamedRepo namedRepo) {
                    return DropdownMenuItem(
                      value: namedRepo,
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
                              Fields.constrainedText(namedRepo.name,
                                  fontWeight: FontWeight.normal),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (namedRepo) async {
                    loggy.app('Selected repository: ${namedRepo?.name}');
                    setState(() {
                      _persistedRepository = namedRepo;
                    });
                    _repositoriesSession.setCurrent(_persistedRepository!.name);
                  },
                ),
              ),
            ),
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Expanded(
                child: Fields.actionText(S.current.actionRename,
                    textFontSize: Dimensions.fontAverage,
                    icon: Icons.edit,
                    iconSize: Dimensions.sizeIconSmall,
                    spacing: Dimensions.spacingHorizontalHalf, onTap: () async {
                  if (_persistedRepository == null) {
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
                              repositoryName:
                                  _repositoriesSession.current!.name),
                        );
                      }).then((newName) {
                    if (newName?.isNotEmpty ?? false) {
                      final oldName = _persistedRepository!.name;
                      setState(() {
                        _persistedRepository = null;
                      });

                      widget.repositoriesCubit
                          .renameRepository(oldName, newName!);
                    }
                  });
                }),
              ),
              Expanded(
                  child: Fields.actionText(S.current.actionShare,
                      textFontSize: Dimensions.fontAverage,
                      icon: Icons.share,
                      iconSize: Dimensions.sizeIconSmall,
                      spacing: Dimensions.spacingHorizontalHalf, onTap: () {
                if (_persistedRepository == null) {
                  return;
                }

                widget.onShareRepository.call();
              })),
              Expanded(
                  child: Fields.actionText(S.current.actionDelete,
                      textFontSize: Dimensions.fontAverage,
                      textColor: Colors.red,
                      icon: Icons.delete,
                      iconSize: Dimensions.sizeIconSmall,
                      iconColor: Colors.red,
                      spacing: Dimensions.spacingHorizontalHalf,
                      onTap: () async {
                if (_persistedRepository == null) {
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
                    final repositoryName = _persistedRepository!.name;
                    setState(() {
                      _persistedRepository = null;
                      _bittorrentDhtStatus = false;
                    });

                    widget.repositoriesCubit.deleteRepository(repositoryName);
                  }
                });
              }))
            ],
          ),
        ]);
  }

  Widget _buildStorageSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Fields.idLabel('Storage',
          fontSize: Dimensions.fontAverage,
          fontWeight: FontWeight.normal,
          color: _titlesColor!
        ),
        Fields.labeledText(
          label: 'Location:',
          text: _storagePath ?? '',
          labelTextAlign: TextAlign.start,
          textAlign: TextAlign.end,
          textOverflow: TextOverflow.visible
        ),
        Visibility(
          visible: !_movingToExternalStorage,
          child: Row(children: [
            Expanded( child: Fields.actionText(
              'Move (external storage)',
              textFontSize: Dimensions.fontAverage,
              textSoftWrap: false,
              textOverflow: TextOverflow.visible,
              icon: Icons.drive_file_move,
              iconSize: Dimensions.sizeIconSmall,
              spacing: Dimensions.spacingHorizontalHalf,
              onTap: () async {
                final rootPath = (await ExternalPath.getExternalStorageDirectories()).first;
                final rootDirectory = Directory(rootPath);

                final path = await FilesystemPicker.open(
                  context: context,
                  fsType: FilesystemType.folder,
                  rootDirectory: rootDirectory,
                  rootName: 'External',
                  title: 'Select the new location',
                  pickText: 'Move OuiSync files to this folder',
                  requestPermission: () async {
                    final status = await Permission.storage.request();
                    return status.isGranted;
                  }
                );

                if (path == null) {
                  return;
                }

                print('Selected path: $path');
                _newStoragePath = path;
                setState(() => _movingToExternalStorage = true);
              }  
            ))
          ])
        ),
        Visibility(
          visible: _movingToExternalStorage,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_downward),
              Fields.labeledText(
                label: 'New location:',
                text: '${_newStoragePath ?? '?'}/ouisync',
                labelTextAlign: TextAlign.start,
                textAlign: TextAlign.end,
                textOverflow: TextOverflow.visible
              ),
              Row(children: [
                Expanded( child: Fields.actionText(
                  'Move',
                  textFontSize: Dimensions.fontAverage,
                  textSoftWrap: false,
                  textOverflow: TextOverflow.visible,
                  icon: Icons.drive_file_move,
                  iconSize: Dimensions.sizeIconSmall,
                  spacing: Dimensions.spacingHorizontalHalf,
                  onTap: () async {
                    assert(_storagePath != null);
                    assert(_newStoragePath != null);

                    final externalStorageRoot = '$_newStoragePath/ouisync';

                    final originPath = await Constants.reposPath;
                    final destinationPath = path.join(externalStorageRoot, Constants.folderRepositoriesName);

                    final exist = await Directory(originPath).exists();
                    if (!exist) {
                      loggy.app('No repositories found in default path. Updating the default path to $destinationPath '
                      'and the storage type to EXTERNAL');

                      Settings.saveSetting(Constants.externalPathKey, externalStorageRoot);
                      Settings.saveSetting(Constants.storageTypeKey, Constants.externalStorage);

                      setState(() {
                        _storagePath = destinationPath;
                        _movingToExternalStorage = false;
                      });

                      Fluttertoast.showToast(msg: 'OuiSync files moved to external storage sucessfuly');

                      return;
                    }
                    
                    // final rootPath = '${_newStoragePath!}/ouisync';
                    loggy.app('Preparing to move repositories to external location $destinationPath');
                    await _moveFilesToExternalStorage(externalStorageRoot, originPath, destinationPath);

                    // await showDialog(
                    //   context: context,
                    //   barrierDismissible: false,
                    //   builder: (BuildContext context) {
                    //     return ActionsDialog(
                    //       title: 'Move OuiSync files to',
                    //       body: ChangeStorageLocation(
                    //         context: context,
                    //         originPath: _storagePath!,
                    //         destinationPath: rootPath,
                    //       ),
                    //     );
                    //   }
                    // );
                  }  
                )),
                Expanded( child: Fields.actionText(
                  'Cancel',
                  textFontSize: Dimensions.fontAverage,
                  textSoftWrap: false,
                  textOverflow: TextOverflow.visible,
                  icon: Icons.cancel,
                  iconSize: Dimensions.sizeIconSmall,
                  spacing: Dimensions.spacingHorizontalHalf,
                  onTap: () => setState(() => _movingToExternalStorage = false) 
                ))
              ])
            ],
          )
        ),
      ]
    );
  }

  Future<void> _moveFilesToExternalStorage(String newExternalRoot, String from, String to) async {
    Directory destination = Directory('$to');

    final exist = await destination.exists();
    if (exist) {
      final isEmpty = await destination.list(recursive: true).isEmpty;
      if (!isEmpty) {
        await _showDestinationContainsFilesDialog(to);
        return;
      }

      loggy.app('Using empty folder for OuiSync at destination: $to');
    }

    loggy.app('Closing repositories...');
    setState(() => _persistedRepository = null);
    _repositoriesSession.close();
    
    // loggy.app('Moving files from $from => $to');
    await copyPath(from, to);

    // loggy.app('Done!');

    // // final finishMovingFiles = await _showConfirmMovingFilesDialog(destinationPath) ?? false;
    // // if (!finishMovingFiles) {
    // //   await _removeDirectoryRecursive(destinationPath);
    // //   return;
    // // }

    // loggy.app('Updating the app settings...');
    Settings.saveSetting(Constants.externalPathKey, newExternalRoot);
    Settings.saveSetting(Constants.storageTypeKey, Constants.externalStorage);

    // loggy.app('Removing old files on $from');
    // await Directory(from).delete(recursive: true);

    // loggy.app('Done!');
    // // await _removeDirectoryRecursive(from);

    setState(() {
      _storagePath = to;
      _movingToExternalStorage = false;
    });

    widget.onRepositorySelect.call(null, '', null);
    widget.resetReposCallback.call();

    Fluttertoast.showToast(msg: 'OuiSync files moved to external storage sucessfuly');
  }

  Future<void> _showDestinationContainsFilesDialog(String destinationPath) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text('Move OuiSync files'),
          content: SingleChildScrollView(
            child: ListBody(children: [
              Text(
                destinationPath,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Dimensions.spacingVerticalDouble,
              Text('This folder seems to contains OuiSync files already.'
              '\r\n\r\n'
              'Please pick a different location.')
            ]),
          ),
          actions: [
            TextButton(
              child: Text(S.current.actionCloseCapital),
              onPressed: () => 
              Navigator.of(context).pop(),
            )
          ],
        );
    });
  }

  Future<bool?> _showConfirmMovingFilesDialog(String destinationPath) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text('Finish moving OuiSync files'),
          content: SingleChildScrollView(
            child: ListBody(children: [
              Text('The files were copied sucesfully.'
              '\r\n\r\n'
              'Do you want to finish the process and delete the files from the origin, or cancel the operation?')
            ]),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.current.actionAccept)
            ),
            Dimensions.spacingActionsHorizontal,
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(S.current.actionCancel)
            ),
          ],
        );
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
            Row(children: [
              Expanded(
                  child: Fields.actionText(S.current.actionSave,
                      textFontSize: Dimensions.fontAverage,
                      icon: Icons.save,
                      iconSize: Dimensions.sizeIconSmall,
                      spacing: Dimensions.spacingHorizontalHalf,
                      onTap: _saveLogs)),
              Expanded(
                  child: Fields.actionText(S.current.actionShare,
                      textFontSize: Dimensions.fontAverage,
                      icon: Icons.share,
                      iconSize: Dimensions.sizeIconSmall,
                      spacing: Dimensions.spacingHorizontalHalf,
                      onTap: _shareLogs))
            ]),
          ]);

  Future<void> updateDhtSetting(bool enable) async {
    if (!_repositoriesSession.hasCurrent) {
      return;
    }

    loggy.app('${enable ? 'Enabling' : 'Disabling'} BitTorrent DHT...');

    enable
        ? await _repositoriesSession.current!.repo.enableDht()
        : await _repositoriesSession.current!.repo.disableDht();

    final isEnabled = await _repositoriesSession.current!.repo.isDhtEnabled();
    setState(() {
      _bittorrentDhtStatus = isEnabled;
    });

    RepositoryHelper.updateBitTorrentDHTForRepoStatus(_repositoriesSession.current!.name, isEnabled);

    String dhtStatusMessage = S.current.messageBitTorrentDHTStatus(isEnabled ? 'enabled' : 'disabled');
    if (enable != isEnabled) {
      dhtStatusMessage = enable
          ? S.current.messageBitTorrentDHTEnableFailed
          : S.current.messageBitTorrentDHTDisableFailed;
    }

    loggy.app(dhtStatusMessage);
    showToast(dhtStatusMessage);
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
    final path = '${dir.path}/$name.log';

    await dumpLogs(path);

    return path;
  }
}
