import 'dart:io' as io;

import 'package:external_path/external_path.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SaveToDevice extends StatefulWidget with OuiSyncAppLogger {
  const SaveToDevice({required this.data, required this.cubit});

  final FileItem data;
  final RepoCubit cubit;

  @override
  State<SaveToDevice> createState() => _SaveToDeviceState();
}

class _SaveToDeviceState extends State<SaveToDevice> {
  List<_Drive>? _drives;
  int _selectedDrive = 0; // Assumes there will always be at least one drive.

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_Drive>>(
        future: _initDrives(),
        builder: (BuildContext context, AsyncSnapshot<List<_Drive>> snapshot) {
          return _buildMainWidget(context, snapshot.data);
        });
  }

  Widget _buildMainWidget(BuildContext context, List<_Drive>? drives) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Fields.constrainedText('"${widget.data.name}"',
                color: Colors.grey.shade800)
          ]),
          Dimensions.spacingVerticalDouble,
          if (drives != null) _buildExternalStorageSelection(drives),
          Dimensions.spacingVertical,
          if (drives != null) _buildDestinationSelection(drives),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Widget _buildDestinationSelection(List<_Drive> drives) {
    final drive = drives[_selectedDrive];

    return Container(
        padding: Dimensions.paddingGreyBox,
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
          color: Colors.grey.shade300,
        ),
        child: Padding(
            padding: Dimensions.paddingGreyBox,
            child: Column(
              children: [
                Row(children: [
                  Fields.constrainedText(S.current.labelDestination,
                      flex: 0,
                      fontSize: Dimensions.fontSmall,
                      fontWeight: FontWeight.w300),
                ]),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Fields.constrainedText(drive.defaultDirRelative()),
                    Fields.actionIcon(const Icon(Icons.more_horiz),
                        onPressed: () async =>
                            await _changeDestinationPath(drives))
                  ],
                )
              ],
            )));
  }

  Widget _buildExternalStorageSelection(List<_Drive> drives) {
    if (drives.length <= 1) {
      return SizedBox.shrink();
    }

    return DropdownButton<int>(
      value: _selectedDrive,
      isExpanded: true,
      onChanged: (int? value) {
        setState(() {
          _selectedDrive = value!;
        });
      },
      items:
          Iterable<int>.generate(drives.length).map<DropdownMenuItem<int>>((i) {
        return DropdownMenuItem<int>(
          value: i,
          child: Text(drives[i].name),
        );
      }).toList(),
    );
  }

  Future<void> _changeDestinationPath(List<_Drive> drives) async {
    final drive = drives[_selectedDrive];

    final path = await FilesystemPicker.open(
        context: context,
        fsType: FilesystemType.folder,
        rootDirectory: drive.root,
        rootName: drive.name,
        directory: drive.defaultDir(),
        title: S.current.messageSelectLocation,
        pickText: S.current.messageSaveToLocation,
        requestPermission: () async {
          final status = await Permission.storage.request();
          return status.isGranted;
        });

    if (path == null) return;
    if (path.isEmpty) return;

    setState(() {
      drive.trySetDefaultDir(path);
    });
  }

  // TODO: Non Android devies.
  Future<List<_Drive>> _initDrives() async {
    var drives = _drives;
    if (drives != null) {
      // Already initialized.
      return drives;
    }

    drives = [];
    _drives = drives;
    // This is a hack, there isn't really a guarantee that the first item is
    // the internal memory and the others are external.
    var i = 0;
    final dirs = await ExternalPath.getExternalStorageDirectories();
    final downloads = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    if (dirs.isEmpty) {
      drives.add(_Drive("Downloads", io.Directory(downloads)));
      return drives;
    }

    for (final dirStr in dirs) {
      final dir = io.Directory(dirStr);
      var storage;
      if (i == 0) {
        storage = _Drive("Internal drive", dir);
      } else {
        if (dirs.length <= 2) {
          storage = _Drive("External drive", dir);
        } else {
          storage = _Drive("External drive #${i - 1}", dir);
        }
      }
      storage.trySetDefaultDir(downloads);
      drives.add(storage);
      i += 1;
    }

    return drives;
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () =>
                Navigator.of(context, rootNavigator: false).pop('')),
        PositiveButton(
            text: S.current.actionSave,
            onPressed: () async {
              await _downloadFile();
            })
      ];

  Future<void> _downloadFile() async {
    final destinationDir = (await _initDrives())[_selectedDrive].defaultDir();

    if (await Permission.storage.request().isGranted) {
      final destinationPath = p.join(destinationDir.path, widget.data.name);

      print("Storing file to $destinationPath");

      widget.cubit.downloadFile(
          sourcePath: widget.data.path, destinationPath: destinationPath);

      Navigator.of(context, rootNavigator: false).pop();
    }
  }
}

class _Drive {
  final String name;
  final io.Directory root;
  io.Directory? _defaultDir; // If set, must be a subdirectory in `root`.

  _Drive(this.name, this.root);

  bool trySetDefaultDir(String defaultDir) {
    if (defaultDir.startsWith(root.path)) {
      _defaultDir = io.Directory(defaultDir);
      return true;
    }
    return false;
  }

  io.Directory defaultDir() {
    final d = _defaultDir;
    if (d != null) {
      return d;
    } else {
      return root;
    }
  }

  String defaultDirRelative() {
    var d = defaultDir().path;
    return d.substring(root.path.length) + "/";
  }
}
