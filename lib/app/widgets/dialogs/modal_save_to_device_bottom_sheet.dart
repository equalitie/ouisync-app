import 'dart:io' as io;

import 'package:external_path/external_path.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';
import '../../cubit/cubits.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SaveToDevice extends StatefulWidget with OuiSyncAppLogger {
  const SaveToDevice({
    Key? key,
    required this.repository,
    required this.data,
    required this.cubit
  }) : super(key: key);

  final RepoState repository;
  final FileItem data;
  final DirectoryCubit cubit;

  @override
  _SaveToDeviceState createState() => _SaveToDeviceState();
}

class _SaveToDeviceState extends State<SaveToDevice> {
  bool _useExternalStorage = false;
  String? _destinationPath;

  @override
  void initState() {
    super.initState();

    setDestinationPath();
  }

  Future<void> setDestinationPath() async {
    final path = await _getDefaultDestinationPath();
    setState(() { _destinationPath = path ?? '?'; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Fields.constrainedText('"${widget.data.name}"', color: Colors.grey.shade800)
        ]),
        Dimensions.spacingVertical,
        _buildDestinationSelection(),
        if (io.Platform.isAndroid)
          _buildExternalStorageSelection(),
        Fields.dialogActions(
          context,
          buttons: _actions(context)
        ),
      ]
    );
  }

  Widget _buildDestinationSelection() {
    return Container(
      padding: Dimensions.paddingGreyBox,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusMicro)),
        border: Border.all(
          color: Colors.black45,
          width: 1.0,
          style: BorderStyle.solid
        ),
        color: Colors.grey.shade300,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Fields.constrainedText(
                S.current.labelDestination,
                flex: 0,
                fontSize: Dimensions.fontSmall,
                fontWeight: FontWeight.w300
              ),
            ]
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Fields.constrainedText(_destinationPath ?? '?'),
              Fields.actionIcon(const Icon(Icons.more_horiz),
                onPressed: () async => await _changeDestinationPath()
              )
            ],
          )
        ],
      ) 
    );
  }

  Widget _buildExternalStorageSelection() {
    return LabeledSwitch(
      label: S.current.labelUseExternalStorage,
      padding: const EdgeInsets.all(0.0),
      value: _useExternalStorage,
      onChanged:(value) async => await _updateDestinationPath(value),
    );
  }

  Future<void> _updateDestinationPath(bool value) async {
    setState(() { _useExternalStorage = value; });
    await setDestinationPath();
  }

  Future<void> _changeDestinationPath() async {
    if (_destinationPath?.isEmpty ?? true) {
      return;
    }

    final defaultDirectory = io.Directory(_destinationPath!);
    final path = await FilesystemPicker.open(
      context: context,
      fsType: FilesystemType.folder,
      rootDirectory: defaultDirectory,
      rootName: S.current.labelDestination,
      title: S.current.messageSelectLocation,
      pickText: S.current.messageSaveToLocation,
      requestPermission: () async {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    );

    if (path?.isEmpty ?? true) {
      return;
    }

    setState(() { _destinationPath = path; });
  }

  Future<String?> _getDefaultDestinationPath() async {
    /// path_provider doesn't support getting the path to the Downloads folder on Android or iOS,
    /// but it does for desktop. So we use it for Windows
    /// For Android we use lecle_downloads_path_provider to get the path to the Download folder,
    /// and external_path for the external storage.
    io.Directory? downloadsPath;
    if (io.Platform.isWindows) {
      downloadsPath = await getDownloadsDirectory();
    } 
    
    if (io.Platform.isAndroid) {
      if (_useExternalStorage) {
        final rootPath = (await ExternalPath.getExternalStorageDirectories()).first;
        downloadsPath = io.Directory(rootPath);
      }
        
      downloadsPath ??= await DownloadsPath.downloadsDirectory();
    }

    downloadsPath ??= await getApplicationDocumentsDirectory();
    return downloadsPath.path;
  }

  List<Widget> _actions(context) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => Navigator.of(context, rootNavigator: false).pop('')),
    PositiveButton(
      text: S.current.actionSave,
      onPressed: () async { await _downloadFile(); })
  ];

  Future<void> _downloadFile() async {
    if (_destinationPath?.isEmpty ?? true) {
      return;
    }

    if (await Permission.storage.request().isGranted) {
      final destinationPath = p.join(_destinationPath!, widget.data.name);
      widget.cubit.downloadFile(
        widget.repository,
        sourcePath: widget.data.path,
        destinationPath: destinationPath
      );

      Navigator.of(context, rootNavigator: false).pop();
    }
  }
}
