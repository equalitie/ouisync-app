import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/log_view_page.dart';
import '../../utils/dump.dart';
import '../../utils/platform/platform.dart';
import '../../utils/constants.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class LogsSection extends SettingsSection {
  final StateMonitor stateMonitor;
  final Cubits _cubits;

  LogsSection(this._cubits)
      : stateMonitor = _cubits.repositories.rootStateMonitor,
        super(title: S.current.titleLogs);

  @override
  List<Widget> buildTiles(BuildContext context) => [
        NavigationTile(
          title: Text(S.current.actionSave),
          leading: Icon(Icons.save),
          onTap: () => unawaited(_saveLogs(context)),
        ),
        // TODO: enable this on desktop as well
        if (PlatformValues.isMobileDevice)
          NavigationTile(
            title: Text(S.current.actionShare),
            leading: Icon(Icons.share),
            onTap: () => unawaited(_shareLogs(context)),
          ),
        NavigationTile(
          title: Text(S.current.messageView),
          leading: Icon(Icons.visibility),
          onTap: () => _viewLogs(context),
        ),
        BlocBuilder<StateMonitorIntCubit, int?>(
            bloc: _cubits.panicCounter,
            builder: (context, count) {
              if ((count ?? 0) > 0) {
                final color = Theme.of(context).colorScheme.error;
                return SettingsTile(
                  title: Text(
                    S.current.messageLibraryPanic,
                    style: TextStyle(color: color),
                  ),
                  leading: Icon(Icons.error, color: color),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
        BlocBuilder<BackgroundServiceManager, BackgroundServiceManagerState>(
            bloc: _cubits.backgroundServiceManager,
            builder: (context, _) {
              if (_cubits.backgroundServiceManager.showWarning()) {
                final color = Constants.warningColor;
                return SettingsTile(
                  title: Text(
                    S.current.messageMissingBackgroundServicePermission,
                    style: TextStyle(color: color),
                  ),
                  leading: Icon(Icons.warning, color: color),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
      ];

  @override
  bool containsErrorNotification() {
    return (_cubits.panicCounter.state ?? 0) > 0;
  }

  @override
  bool containsWarningNotification() {
    return _cubits.backgroundServiceManager.showWarning();
  }

  Future<void> _saveLogs(BuildContext context) async {
    final tempFile = await _dumpInfo(context);

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final params = SaveFileDialogParams(sourceFilePath: tempFile.path);
        await FlutterFileDialog.saveFile(params: params);
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        final initialDir = await getDownloadsDirectory();
        final outputPath = await FilePicker.platform.saveFile(
            fileName: basename(tempFile.path),
            initialDirectory: initialDir?.path);

        if (outputPath != null) {
          await tempFile.copy(outputPath);
        }
      }
    } finally {
      await tempFile.delete();
    }
  }

  Future<void> _shareLogs(BuildContext context) async {
    final tempFile = await _dumpInfo(context);

    try {
      await Share.shareXFiles([XFile(tempFile.path, mimeType: 'text/plain')]);
    } finally {
      await tempFile.delete();
    }
  }

  void _viewLogs(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogViewPage(),
      ));

  Future<File> _dumpInfo(
    BuildContext context,
  ) =>
      dumpAll(context, stateMonitor);
}
