import 'dart:convert';
import 'dart:io';

import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart' as o;
import 'package:path/path.dart';
import 'package:watcher/watcher.dart';

import 'ansi_parser.dart';
import 'constants.dart';
import 'native.dart';

class LogUtils {
  LogUtils._();

  /// Path to the log file
  static Future<String> get path async {
    final appDir = await Native.getBaseDir();
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

/// Mixin that adds getter that returns logger tagged with the name of the class it's mixed into.
mixin AppLogger implements LoggyType {
  @override
  Loggy<LoggyType> get loggy => Loggy<AppLogger>(runtimeType.toString());
}

/// Returns logger tagged with the given class name. Useful for logging from static methods.
Loggy<LoggyType> staticLogger<T>() => Loggy<AppLogger>((T).toString());

const LogLevel appLevel = LogLevel('Ouisync', 2); // 2 == debug

extension AppLoggy on Loggy {
  void app(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(appLevel, message, error, stackTrace);
}

class AppLogPrinter extends LoggyPrinter {
  @override
  void onLog(LogRecord record) {
    final level = _convertLogLevel(record.level);

    final message = StringBuffer(record.message);

    if (record.error != null) {
      message.write(' ${record.error}');
    }

    if (record.stackTrace != null) {
      message.write('\n${record.stackTrace}');
    }

    if (Platform.isMacOS || Platform.isIOS) {
      print("$level ${record.loggerName} $message");
    } else {
      // TODO: this goes via flutter channel
      o.logPrint(level, record.loggerName, message.toString());
    }
  }
}

o.LogLevel _convertLogLevel(LogLevel level) {
  if (level.priority == 1) {
    return o.LogLevel.trace;
  }

  if (level.priority == LogLevel.debug.priority) {
    return o.LogLevel.debug;
  }

  if (level.priority == LogLevel.info.priority) {
    return o.LogLevel.info;
  }

  if (level.priority == LogLevel.warning.priority) {
    return o.LogLevel.warn;
  }

  if (level.priority == LogLevel.error.priority) {
    return o.LogLevel.error;
  }

  throw 'unsupported log level $level';
}
