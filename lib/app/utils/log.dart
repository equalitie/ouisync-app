import 'dart:io';

/// Save logs to the specified file.
Future<void> dumpLogs(String outputPath) async {
  final logcat = await Process.start('logcat', [
    '-d',
    '-vlong',
    '-vyear',
    '-vUTC',
    '*:S',
    'flutter:V',
    'flutter-ouisync:V'
  ]);

  final file = File(outputPath);
  final sink = file.openWrite();
  await sink.addStream(logcat.stdout);
  await sink.close();
}
