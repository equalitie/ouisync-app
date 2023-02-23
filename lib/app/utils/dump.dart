import 'dart:convert';
import 'dart:io';

import 'package:ouisync_plugin/state_monitor.dart';

import 'ansi_parser.dart';

Future<void> dumpAll(IOSink sink, StateMonitor rootMonitor) async {
  sink.writeln(
      "------------------------- State Monitor -------------------------\n\n");

  await _dumpStateMonitor(sink, rootMonitor, 0);

  sink.writeln(
      "\n\n---------------------------- LogCat -----------------------------\n\n");

  await _dumpLogs(sink);
}

/// Dump logcat
Future<void> _dumpLogs(IOSink sink) async {
  final logcat = await Process.start('logcat', [
    '-d',
    '-vlong',
    '-vyear',
    '-vUTC',
    '*:S',
    'flutter:V',
    'flutter-ouisync:V'
  ]);

  await sink.addStream(logcat.stdout
      .map((chunk) => utf8.encode(removeAnsi(utf8.decode(chunk)))));
}

/// Dump content of the state monitor
Future<void> _dumpStateMonitor(
  IOSink sink,
  StateMonitor monitor,
  int depth,
) async {
  final node = await monitor.load();

  final pad = '  ' * depth;
  if (node == null) {
    sink.writeln("${pad}null");
    return;
  }

  for (MapEntry e in node.values.entries) {
    sink.writeln("$pad${e.key}: ${e.value}");
  }

  for (MonitorId child in node.children.keys) {
    sink.writeln("$pad$child");
    await _dumpStateMonitor(sink, monitor.child(child), depth + 1);
  }
}
