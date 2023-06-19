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
    final main = File(await path);
    final all = await main.parent
        .list()
        .map((entry) => entry.absolute.path)
        .where((path) => path.startsWith(main.path))
        .toList();

    // The logs files are named 'ouisync.log', 'ouisync.log.1', 'ouisync.log.2', ... so sorting
    // them in reverse lexigographical order yields them from the oldest to the newest.
    all.sort((a, b) => b.compareTo(a));

    for (final path in all) {
      await sink.addStream(File(path)
          .openRead()
          .map((chunk) => utf8.encode(removeAnsi(utf8.decode(chunk)))));
    }
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
