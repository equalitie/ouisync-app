import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

import 'ansi_parser.dart';
import 'constants.dart';

class LogUtils {
  LogUtils._();

  /// Path to the log file
  static Future<String> get path async {
    final appDir = await getApplicationSupportDirectory();
    return join(appDir.path, "logs", Constants.logFileName);
  }

  /// Dump logs to the given sink
  static Future<void> dump(IOSink sink) async {
    final file = File(await path);
    final stream = file
        .openRead()
        .map((chunk) => utf8.encode(removeAnsi(utf8.decode(chunk))));

    await sink.addStream(stream);
  }

  /// Watch the log
  static Stream<List<int>> get watch async* {
    final reader = _Reader(File(await path));

    // First yield the whole file
    yield* reader.read();

    // Then watch for changes and yield them as they come
    final watcher = FileWatcher(reader.file.path);

    await for (final _ in watcher.events) {
      yield* reader.read();
    }
  }
}

class _Reader {
  final File file;
  int offset = 0;

  _Reader(this.file);

  Stream<List<int>> read() {
    return file.openRead(offset).map((chunk) {
      offset += chunk.length;
      return chunk;
    });
  }
}
