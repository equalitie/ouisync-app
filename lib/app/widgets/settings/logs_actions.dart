import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../utils/dump.dart';
import '../../utils/settings.dart';
import '../../pages/log_view_page.dart';

class LogsActions {
  final Settings settings;
  final StateMonitor stateMonitor;

  LogsActions({required this.settings, required this.stateMonitor});

  Future<void> saveLogs(BuildContext context) async {
    final tempFile = await _dumpInfo(context);

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final params = SaveFileDialogParams(sourceFilePath: tempFile.path);
        await FlutterFileDialog.saveFile(params: params);
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        final outputPath =
            await FilePicker.platform.saveFile(fileName: tempFile.path);

        if (outputPath != null) {
          await tempFile.copy(outputPath);
        }
      }
    } finally {
      await tempFile.delete();
    }
  }

  Future<void> shareLogs(BuildContext context) async {
    final tempFile = await _dumpInfo(context);

    try {
      await Share.shareXFiles([XFile(tempFile.path, mimeType: 'text/plain')]);
    } finally {
      await tempFile.delete();
    }
  }

  void viewLogs(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogViewPage(settings: settings),
      ));

  Future<File> _dumpInfo(
    BuildContext context,
  ) =>
      dumpAll(context, stateMonitor);
}
