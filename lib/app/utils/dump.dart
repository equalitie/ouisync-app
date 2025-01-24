import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ouisync/state_monitor.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../cubits/connectivity_info.dart';
import '../cubits/nat_detection.dart';
import '../cubits/power_control.dart';
import 'log.dart';

Future<File> dumpAll(
  BuildContext context, {
  required StateMonitor rootMonitor,
  required PowerControl powerControl,
  required ConnectivityInfo connectivityInfo,
  required NatDetection natDetection,
  bool compress = false,
}) async {
  final dir = await getTemporaryDirectory();
  final info = await PackageInfo.fromPlatform();
  final name = info.appName.toLowerCase();

  final connType = powerControl.state.connectivityType;
  final connInfo = connectivityInfo.state;
  final natType = natDetection.state;

  // TODO: Add time zone, at time of this writing, time zones have not yet
  // been implemented by DateFormat.
  final formatter = DateFormat('yyyy-MM-dd--HH-mm-ss');
  final timestamp = formatter.format(DateTime.now());
  final path = join(dir.path, '$name--$timestamp.log');
  final file = File(path);
  final sink = file.openWrite();

  try {
    sink.writeln("appName: ${info.appName}");
    sink.writeln("packageName: ${info.packageName}");
    sink.writeln("version: ${info.version}");
    sink.writeln("buildNumber: ${info.buildNumber}");

    sink.writeln("connectionType: $connType");
    sink.writeln("localAddressV4: ${connInfo.localAddressV4}");
    sink.writeln("localAddressV6: ${connInfo.localAddressV6}");
    sink.writeln("externalAddressV4: ${connInfo.externalAddressV4}");
    sink.writeln("externalAddressV6: ${connInfo.externalAddressV6}");
    sink.writeln("NAT type: $natType");
    sink.writeln("listenerAddrs:  ${connInfo.listenerAddrs}");

    sink.writeln(
        "\n\n------------------------- State Monitor -------------------------\n\n");
    await _dumpStateMonitor(sink, rootMonitor, 0);

    sink.writeln(
        "\n\n------------------------- Logs ----------------------------------\n\n");
    await LogUtils.dump(sink);
  } finally {
    await sink.close();
  }

  if (compress) {
    final path = '${file.path}.zip';

    final encoder = ZipFileEncoder();
    encoder.create(path);
    await encoder.addFile(file);
    await encoder.close();

    return File(path);
  } else {
    return file;
  }
}

/// Dump content of the state monitor
Future<void> _dumpStateMonitor(
  IOSink sink,
  StateMonitor monitor,
  int depth,
) async {
  final node = await monitor.load();

  if (node == null) {
    return;
  }

  final pad = '  ' * depth;

  for (MapEntry e in node.values.entries) {
    sink.writeln("$pad${e.key}: ${e.value}");
  }

  for (MonitorId child in node.children) {
    sink.writeln("$pad$child");
    await _dumpStateMonitor(sink, monitor.child(child), depth + 1);
  }
}
