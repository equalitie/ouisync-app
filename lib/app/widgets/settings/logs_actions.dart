import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/dump.dart';
import '../../utils/settings.dart';
import '../../pages/log_view_page.dart';

class LogsActions {
  final Settings settings;
  final StateMonitor stateMonitor;

  LogsActions({required this.settings, required this.stateMonitor});

  Future<void> saveLogs(BuildContext context) async {
    final tempPath = await _dumpInfo(context);
    final params = SaveFileDialogParams(sourceFilePath: tempPath);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> shareLogs(BuildContext context) async {
    final tempPath = await _dumpInfo(context);
    await Share.shareXFiles([XFile(tempPath, mimeType: 'text/plain')]);
  }

  void viewLogs(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogViewPage(settings: settings),
      ));

  Future<String> _dumpInfo(
    BuildContext context,
  ) =>
      dumpAll(context, stateMonitor);
}
