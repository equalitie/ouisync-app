import 'dart:io';
import 'package:ouisync_plugin/state_monitor.dart';

Future<void> dumpAll(IOSink sink, StateMonitor? rootMonitor) async {
    sink.writeln("------------------------- State Monitor -------------------------\n\n");

    _dumpStateMonitor(sink, rootMonitor, 0);

    sink.writeln("\n\n---------------------------- LogCat -----------------------------\n\n");

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

  await sink.addStream(logcat.stdout);
}

/// Dump content of the state monitor
void _dumpStateMonitor(IOSink sink, StateMonitor? node, int depth) {
    final pad = '  ' * depth;
    if (node == null) {
      sink.writeln("${pad}null");
      return;
    }

    for (MapEntry e in node.values.entries) {
        sink.writeln("${pad}${e.key}: ${e.value}");
    }

    for (String child in node.children.keys) {
        sink.writeln("${pad}${child}");
        _dumpStateMonitor(sink, node.child(child), depth + 1);
    }
}
