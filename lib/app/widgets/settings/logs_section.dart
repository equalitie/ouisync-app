import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/log_view_page.dart';
import '../../utils/constants.dart';
import '../../utils/dump.dart';
import '../../utils/log.dart';
import '../../utils/platform/platform.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class LogsSection extends SettingsSection with AppLogger {
  final StateMonitor stateMonitor;
  final Cubits _cubits;

  LogsSection(this._cubits)
      : stateMonitor = _cubits.repositories.rootStateMonitor,
        super(title: S.current.titleLogs);

  TextStyle? bodyStyle;

  @override
  List<Widget> buildTiles(BuildContext context) {
    bodyStyle = Theme.of(context).textTheme.bodyMedium;

    final mountCubit = _cubits.mount;

    return [
      NavigationTile(
        title: Text(S.current.actionSave, style: bodyStyle),
        leading: Icon(Icons.save),
        onTap: () => unawaited(_saveLogs(context)),
      ),
      // TODO: enable this on desktop as well
      if (PlatformValues.isMobileDevice)
        NavigationTile(
          title: Text(S.current.actionShare, style: bodyStyle),
          leading: Icon(Icons.share),
          onTap: () => unawaited(_shareLogs(context)),
        ),
      NavigationTile(
        title: Text(S.current.messageView, style: bodyStyle),
        leading: Icon(Icons.visibility),
        onTap: () => _viewLogs(context),
      ),
      BlocBuilder<StateMonitorIntCubit, int?>(
          bloc: _cubits.panicCounter,
          builder: (context, count) {
            if ((count ?? 0) == 0) {
              return SizedBox.shrink();
            }
            return _errorTile(context, S.current.messageLibraryPanic);
          }),
      BlocBuilder<BackgroundServiceManager, BackgroundServiceManagerState>(
          bloc: _cubits.backgroundServiceManager,
          builder: (context, _) {
            if (!_cubits.backgroundServiceManager.showWarning()) {
              return SizedBox.shrink();
            }
            return _warningTile(
                context, S.current.messageMissingBackgroundServicePermission);
          }),
      if (mountCubit != null)
        BlocBuilder<MountCubit, MountState>(
            bloc: mountCubit,
            builder: (context, error) {
              if (error is! MountStateError) {
                return SizedBox.shrink();
              }

              String reason;
              Widget? trailing;
              void Function()? onTap;

              if (error.code == oui.ErrorCode.vfsDriverInstall) {
                reason =
                    S.current.messageErrorDokanNotInstalled(Constants.dokanUrl);
                trailing = Icon(Icons.open_in_browser);
                onTap = () {
                  unawaited(launchUrl(Uri.parse(Constants.dokanUrl)));
                };
              } else {
                reason = error.message;
              }

              return _errorTile(context, S.current.messageFailedToMount(reason),
                  trailing: trailing, onTap: onTap);
            })
    ];
  }

  Widget _errorTile(BuildContext context, String str,
      {Widget? trailing, void Function()? onTap}) {
    final color = Theme.of(context).colorScheme.error;
    return SettingsTile(
        title: Text(str, style: bodyStyle?.copyWith(color: color)),
        leading: Icon(Icons.error, color: color),
        trailing: trailing,
        onTap: onTap);
  }

  Widget _warningTile(BuildContext context, String str) {
    final color = Constants.warningColor;
    return SettingsTile(
        title: Text(str, style: bodyStyle?.copyWith(color: color)),
        leading: Icon(Icons.warning, color: color));
  }

  @override
  bool containsErrorNotification() {
    return (_cubits.panicCounter.state ?? 0) > 0 ||
        _cubits.mount?.state is MountStateError;
  }

  @override
  bool containsWarningNotification() {
    return _cubits.backgroundServiceManager.showWarning();
  }

  Future<void> _saveLogs(BuildContext context) async {
    final tempFile = await _dumpInfo(context);

    loggy.debug('Saving logs');

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final params = SaveFileDialogParams(sourceFilePath: tempFile.path);
        final outputPath = await FlutterFileDialog.saveFile(params: params);

        if (outputPath != null) {
          loggy.debug('Logs saved to $outputPath');
        }
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        final initialDir = await getDownloadsDirectory();
        final outputPath = await FilePicker.platform.saveFile(
            fileName: basename(tempFile.path),
            initialDirectory: initialDir?.path);

        if (outputPath != null) {
          await tempFile.copy(outputPath);
          loggy.debug('Logs saved to $outputPath');
        }
      } else {
        loggy.error(
            'Cannot save logs - unsupported platform: ${Platform.operatingSystem}');
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
