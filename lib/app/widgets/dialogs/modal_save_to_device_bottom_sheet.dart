import 'dart:io' as io;

import 'package:external_path/external_path.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
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
  String? destinationDir;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Dimensions.spacingVertical,
          Row(children: [
            Fields.constrainedText('"${widget.data.name}"',
                color: Colors.grey.shade800)
          ]),
          Dimensions.spacingVerticalDouble,
          _locationPicker(),
          Dimensions.spacingVertical,
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Widget _locationPicker() {
    if (io.Platform.isAndroid) {
      return PickLocationAndroid((String d) => setState(() {
            destinationDir = d;
          }));
    } else {
      return PickLocationNonAndroid((String d) => setState(() {
            destinationDir = d;
          }));
    }
  }

  List<Widget> _actions(context) {
    final dst = destinationDir;

    return [
      NegativeButton(
          text: S.current.actionCancel,
          onPressed: () => Navigator.of(context, rootNavigator: false).pop(''),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
      if (dst != null)
        PositiveButton(
            text: S.current.actionSave,
            onPressed: () async {
              await _downloadFile(dst);
            },
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
    ];
  }

  Future<void> _downloadFile(String destinationDir) async {
    if (await Permission.storage.request().isGranted) {
      final destinationPath = p.join(destinationDir, widget.data.name);

      print("Storing file to $destinationPath");

      await widget.cubit.downloadFile(
        sourcePath: widget.data.path,
        destinationPath: destinationPath,
      );

      Navigator.of(context, rootNavigator: false).pop();
    }
  }
}

// ---------------------------------------------------------------------------------------
// Non Android
// ---------------------------------------------------------------------------------------
class PickLocationNonAndroid extends StatefulWidget {
  final void Function(String) onDestinationSelected;

  const PickLocationNonAndroid(this.onDestinationSelected);

  @override
  State<PickLocationNonAndroid> createState() =>
      _PickLocationNonAndroidState(onDestinationSelected);
}

class _PickLocationNonAndroidState extends State<PickLocationNonAndroid> {
  String? _selectedPath;
  final void Function(String) _onDestinationSelected;

  _PickLocationNonAndroidState(this._onDestinationSelected);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _determineDefault(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          final dst = snapshot.data;
          return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dst != null) _buildDestinationSelection(dst),
              ]);
        });
  }

  Future<String?> _determineDefault() async {
    var selectedPath = _selectedPath;
    if (selectedPath != null) return selectedPath;

    if (io.Platform.isWindows) {
      selectedPath = (await getDownloadsDirectory())?.path;
    }

    selectedPath ??= (await getApplicationDocumentsDirectory()).path;

    _selectedPath = selectedPath;
    _onDestinationSelected(selectedPath);

    return selectedPath;
  }

  Widget _buildDestinationSelection(String dst) {
    return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Fields.constrainedText(dst, color: Colors.black),
                Fields.actionIcon(const Icon(Icons.more_horiz),
                    color: Colors.black,
                    onPressed: () async => await _changeDestinationPath(dst))
              ],
            )
          ],
        ));
  }

  Future<void> _changeDestinationPath(String currentDestination) async {
    final path = await FilesystemPicker.open(
        context: context,
        fsType: FilesystemType.folder,
        rootDirectory: io.Directory(currentDestination),
        title: S.current.messageSelectLocation,
        pickText: S.current.messageSaveToLocation,
        requestPermission: () async {
          final status = await Permission.storage.request();
          return status.isGranted;
        });

    if (path == null) return;
    if (path.isEmpty) return;

    setState(() {
      _selectedPath = path;
    });
  }
}

// ---------------------------------------------------------------------------------------
// Android
// ---------------------------------------------------------------------------------------
class PickLocationAndroid extends StatefulWidget {
  final void Function(String) _onDestinationSelected;

  const PickLocationAndroid(this._onDestinationSelected);

  @override
  State<PickLocationAndroid> createState() =>
      _PickLocationAndroidState(_onDestinationSelected);
}

class _PickLocationAndroidState extends State<PickLocationAndroid> {
  List<_Drive>? _drives;
  int _selectedDrive = 0; // Assumes there will always be at least one drive.
  final void Function(String) _onDestinationSelected;

  _PickLocationAndroidState(this._onDestinationSelected);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_Drive>>(
        future: _initDrives(),
        builder: (BuildContext context, AsyncSnapshot<List<_Drive>> snapshot) {
          final drives = snapshot.data;
          return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (drives != null) _buildExternalStorageSelection(drives),
                Dimensions.spacingVertical,
                if (drives != null) _buildDestinationSelection(drives),
              ]);
        });
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

  Widget _buildDestinationSelection(List<_Drive> drives) {
    final drive = drives[_selectedDrive];

    return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Fields.constrainedText(drive.defaultDirRelative(),
                    color: Colors.black),
                Fields.actionIcon(const Icon(Icons.more_horiz),
                    onPressed: () async => await _changeDestinationPath(drives))
              ],
            )
          ],
        ));
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
      if (drive.trySetDefaultDir(path)) {
        _onDestinationSelected(drive.defaultDir().path);
      }
    });
  }

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
      _Drive storage;
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

    _onDestinationSelected(drives[_selectedDrive].defaultDir().path);

    return drives;
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
    return "${d.substring(root.path.length)}/";
  }
}
