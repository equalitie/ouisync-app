import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SaveToDevice extends StatefulWidget with AppLogger {
  const SaveToDevice({required this.data, required this.cubit});

  final FileItem data;
  final RepoCubit cubit;

  @override
  State<SaveToDevice> createState() => _SaveToDeviceState();
}

class _SaveToDeviceState extends State<SaveToDevice> with AppLogger {
  String? destinationPath;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.grey.shade800);

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Dimensions.spacingVertical,
          Row(children: [
            Fields.constrainedText('"${widget.data.name}"', style: bodyStyle)
          ]),
          Dimensions.spacingVerticalDouble,
          _pickFile(),
          Dimensions.spacingVertical,
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Widget _pickFile() => PickFile(
        value: destinationPath,
        fileName: widget.data.name,
        onChanged: (path) => setState(() {
          destinationPath = path;
        }),
      );

  List<Widget> _actions(context) {
    final path = destinationPath;

    return [
      NegativeButton(
        text: S.current.actionCancel,
        onPressed: () => Navigator.of(context, rootNavigator: false).pop(''),
        buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
      ),
      if (path != null)
        PositiveButton(
          text: S.current.actionSave,
          onPressed: () => _downloadFile(context, path),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        )
    ];
  }

  Future<void> _downloadFile(
    BuildContext context,
    String destinationPath,
  ) async {
    loggy.debug('Storing file to $destinationPath');

    await widget.cubit.downloadFile(
      sourcePath: widget.data.path,
      destinationPath: destinationPath,
    );

    Navigator.of(context, rootNavigator: false).pop();
  }
}

class PickFile extends StatelessWidget {
  final String? value;
  final void Function(String) onChanged;
  final String fileName;

  const PickFile(
      {required this.value, required this.onChanged, required this.fileName});

  @override
  Widget build(BuildContext context) => FutureBuilder<io.File?>(
        future: _getDefault(),
        builder: (context, snapshot) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (snapshot.hasData) _buildPicker(snapshot.data),
            ]),
      );

  Future<io.File?> _getDefault() async {
    final filePath = value;

    if (filePath != null) {
      return io.File(filePath);
    }

    final parent = await getDownloadsDirectory();
    if (parent == null) {
      return null;
    }

    final file = io.File(p.join(parent.path, fileName));

    onChanged(file.path);

    return file;
  }

  Widget _buildPicker(io.File? file) => Container(
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
                Fields.constrainedText(
                  file?.path ?? '',
                  // TODO: It would be better here to have the ellipsis at the beginning rather
                  // than the end of the text. Is there a way?
                  textOverflow: TextOverflow.ellipsis,
                ),
                Fields.actionIcon(
                  const Icon(Icons.more_horiz),
                  color: Colors.black,
                  onPressed: () => _openPicker(file),
                )
              ],
            )
          ],
        ),
      );

  Future<void> _openPicker(io.File? oldFile) async {
    final newFile = (io.Platform.isAndroid || io.Platform.isIOS)
        ? await _openPickerMobile(oldFile)
        : await _openPickerDesktop(oldFile);

    if (newFile != null) {
      onChanged(newFile.path);
    }
  }

  Future<io.File?> _openPickerMobile(io.File? file) async {
    final initialDirectory = file?.parent;

    final directoryPath = await FilePicker.platform.getDirectoryPath(
      initialDirectory: initialDirectory?.path,
    );

    if (directoryPath == null || directoryPath.isEmpty) {
      return null;
    }

    return io.File(p.join(directoryPath, fileName));
  }

  Future<io.File?> _openPickerDesktop(io.File? file) async {
    final filePath = await FilePicker.platform.saveFile(
      fileName: file?.fileName ?? fileName,
      initialDirectory: file?.parent.path,
    );

    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    return io.File(filePath);
  }
}

extension FileExtension on io.File {
  String get fileName => p.basename(path);
}
