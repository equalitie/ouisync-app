import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:ouisync/ouisync.dart' show VfsDriverInstallError;
import 'package:ouisync/state_monitor.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/log_view_page.dart';
import '../../utils/dirs.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class LogsSection extends SettingsSection with AppLogger {
  final StateMonitor stateMonitor;
  final MountCubit mount;
  final StateMonitorIntCubit panicCounter;
  final PowerControl powerControl;
  final ReposCubit reposCubit;
  final ConnectivityInfo connectivityInfo;
  final NatDetection natDetection;
  final void Function() checkForDokan;
  final Dirs dirs;

  LogsSection({
    required this.mount,
    required this.panicCounter,
    required this.powerControl,
    required this.reposCubit,
    required this.connectivityInfo,
    required this.natDetection,
    required this.checkForDokan,
    required this.dirs,
  })  : stateMonitor = reposCubit.rootStateMonitor,
        super(
          key: GlobalKey(debugLabel: 'key_logs_section'),
          title: S.current.titleLogs,
        );

  TextStyle? bodyStyle;

  @override
  List<Widget> buildTiles(BuildContext context) {
    bodyStyle = context.theme.appTextStyle.bodyMedium;

    return [
      NavigationTile(
        title: Text(S.current.actionSave, style: bodyStyle),
        leading: Icon(Icons.save),
        onTap: () => unawaited(_saveLogs(context, natDetection)),
      ),
      // TODO: enable this on desktop as well
      if (PlatformValues.isMobileDevice)
        NavigationTile(
          title: Text(S.current.actionShare, style: bodyStyle),
          leading: Icon(Icons.share),
          onTap: () => unawaited(_shareLogs(context, natDetection)),
        ),
      NavigationTile(
        title: Text(S.current.messageView, style: bodyStyle),
        leading: Icon(Icons.visibility),
        onTap: () => _viewLogs(context),
      ),
      BlocBuilder<StateMonitorIntCubit, int?>(
          bloc: panicCounter,
          builder: (context, count) {
            if ((count ?? 0) == 0) {
              return SizedBox.shrink();
            }
            return _errorTile(context, S.current.messageLibraryPanic);
          }),
      BlocBuilder<MountCubit, MountState>(
          bloc: mount,
          builder: (context, result) {
            if (result is! MountStateFailure) {
              return SizedBox.shrink();
            }

            String reason;
            Widget? trailing;
            void Function()? onTap;

            if (result.error is VfsDriverInstallError) {
              reason = S.current.messageErrorDokanNotInstalled('');
              trailing = Icon(Icons.open_in_browser);
              onTap = () {
                // unawaited(launchUrl(Uri.parse(Constants.dokanUrl)));
                checkForDokan();
              };
            } else {
              reason = result.error.toString();
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

  @override
  bool containsErrorNotification() =>
      (panicCounter.state ?? 0) > 0 || mount.state is MountStateFailure;

  Future<void> _saveLogs(
      BuildContext context, NatDetection natDetection) async {
    final tempFile = await _dumpInfo(context, natDetection);

    loggy.debug('Saving logs');

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final params = SaveFileDialogParams(sourceFilePath: tempFile.path);
        final outputPath = await FlutterFileDialog.saveFile(params: params);

        if (outputPath != null) {
          loggy.debug('Logs saved to $outputPath');
        }
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        final outputPath = await FilePicker.platform.saveFile(
          fileName: basename(tempFile.path),
          initialDirectory: dirs.download,
        );

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

  Future<void> _shareLogs(
      BuildContext context, NatDetection natDetection) async {
    final tempFile = await _dumpInfo(context, natDetection);

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
    NatDetection natDetection,
  ) =>
      dumpAll(
        context,
        connectivityInfo: connectivityInfo,
        natDetection: natDetection,
        powerControl: powerControl,
        rootMonitor: stateMonitor,
      );
}
