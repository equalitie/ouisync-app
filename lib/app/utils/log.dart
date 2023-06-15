import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'ansi_parser.dart';
import 'constants.dart';

/// Path to the log file
Future<String> logPath() async {
  final appDir = await getApplicationSupportDirectory();
  return join(appDir.path, "logs", Constants.logFileName);
}

/// Dump logs to the given sink
Future<void> dumpLogs(IOSink sink) async {
  final file = File(await logPath());
  final stream = file
      .openRead()
      .map((chunk) => utf8.encode(removeAnsi(utf8.decode(chunk))));

  await sink.addStream(stream);
}
