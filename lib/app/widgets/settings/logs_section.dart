import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:cross_file/cross_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';

import 'navigation_tile.dart';

class LogsSection extends AbstractSettingsSection {
  final Settings settings;
  final ReposCubit repos;
  final StateMonitorIntValue panicCounter;

  LogsSection({
    required this.settings,
    required this.repos,
    required this.panicCounter,
  });

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: Text(S.current.titleLogs),
        tiles: [
          NavigationTile(
            title: Text(S.current.actionSave),
            leading: Icon(Icons.save),
            onPressed: _saveLogs,
          ),
          NavigationTile(
            title: Text(S.current.actionShare),
            leading: Icon(Icons.share),
            onPressed: _shareLogs,
          ),
          NavigationTile(
            title: Text('View'), // TODO: localize
            leading: Icon(Icons.visibility),
            onPressed: (context) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogViewPage(settings: settings),
                )),
          ),
          CustomSettingsTile(child: panicCounter.builder((context, count) {
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
          })),
        ],
      );

  Future<void> _saveLogs(BuildContext context) async {
    final tempPath = await _dumpInfo(context);
    final params = SaveFileDialogParams(sourceFilePath: tempPath);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> _shareLogs(BuildContext context) async {
    final tempPath = await _dumpInfo(context);
    await Share.shareXFiles([XFile(tempPath, mimeType: 'text/plain')]);
  }

  Future<String> _dumpInfo(BuildContext context) async {
    final dir = await getTemporaryDirectory();
    final info = await PackageInfo.fromPlatform();
    final name = info.appName.toLowerCase();

    final connType = context.read<PowerControl>().state.connectivityType;
    final connInfo = context.read<ConnectivityInfo>().state;

    // TODO: Add time zone, at time of this writing, time zones have not yet
    // been implemented by DateFormat.
    final formatter = DateFormat('yyyy-MM-dd--HH-mm-ss');
    final timestamp = formatter.format(DateTime.now());
    final path = buildDestinationPath(dir.path, '$name--$timestamp.log');
    final outFile = File(path);

    final sink = outFile.openWrite();

    try {
      sink.writeln("appName: ${info.appName}");
      sink.writeln("packageName: ${info.packageName}");
      sink.writeln("version: ${info.version}");
      sink.writeln("buildNumber: ${info.buildNumber}");

      sink.writeln("connectionType: $connType");
      sink.writeln("externalIP: ${connInfo.externalIP}");
      sink.writeln("localIPv4: ${connInfo.localIPv4}");
      sink.writeln("localIPv6: ${connInfo.localIPv6}");
      sink.writeln("tcpListenerV4:  ${connInfo.tcpListenerV4}");
      sink.writeln("tcpListenerV6:  ${connInfo.tcpListenerV6}");
      sink.writeln("quicListenerV4: ${connInfo.quicListenerV4}");
      sink.writeln("quicListenerV6: ${connInfo.quicListenerV6}");
      sink.writeln("\n");

      await dumpAll(sink, repos.session.getRootStateMonitor());
    } finally {
      await sink.close();
    }

    return path;
  }
}
