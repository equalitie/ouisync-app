import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart' as ouisync;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:watcher/watcher.dart';

import 'ansi_parser.dart';
import 'constants.dart';
import 'native.dart';

// a singleton class that deals with logs (currently without rotation)
class LogUtils extends LoggyPrinter {
  /// Dump all logs from the log folder to the given sink
  static Future<void> dump(IOSink sink) async {
    final main = File(await _current);
    final all = await main.parent
        .list()
        .map((entry) => entry.absolute.path)
        .where((path) => path.startsWith(main.path))
        .toList();

    // The logs files are named 'ouisync.log', 'ouisync.log.1', 'ouisync.log.2',
    // etc. so sorting them in reverse lexigographical order yields them from
    // the oldest to the newest. FIXME: what about 'ouisync.log.10'?
    all.sort((a, b) => b.compareTo(a));

    for (final path in all) {
      await sink.addStream(File(path)
          .openRead()
          .map((chunk) => utf8.encode(removeAnsi(utf8.decode(chunk)))));
    }
  }

  /// Watch the log for changes
  static Stream<List<int>> get watch async* {
    final file = File(await _current);
    int offset = 0;

    // open `file` and tail (unix) from `offset` to eof, updating `offset` in
    // the process; unfortunately, posix locks are per process so this results
    // in lost data even when another isolate (or isolate) truncates the file
    // TODO: the correct solution is to just not do this and otherwise defer to
    // native to supply the path to all the (ideally compressed) logs to share
    Stream<List<int>> tail() => file.openRead(offset).map((chunk) {
          offset += chunk.length;
          return chunk;
        });

    yield* tail(); // first yield the whole file as is right now then...
    await for (final _ in FileWatcher(file.path).events) {
      // watch for changes
      yield* tail(); // ...and yield them as they come
    }
  }

  static RandomAccessFile? _fd;

  static Future<void> init() async {
    // our logs can contain data from multiple invocations, so to differentiate
    // we write this header every time the app starts
    final package = await PackageInfo.fromPlatform();
    final baseDir = await Native.getBaseDir();
    final header = '''
-------------------- ${package.appName} Start --------------------
 version: ${package.version} (build ${package.buildNumber})
 started: ${DateTime.now().toUtc().toIso8601String()}
platform: ${Platform.operatingSystemVersion}
 baseDir: ${baseDir.path}
${'-' * (48 + package.appName.length)}
''';
    // Sets up logging, either via a flutter channel (if implemented on the
    // native side) or directly to a file local to the baseDir exposed by native
    try {
      await Native.log(ouisync.LogLevel.info, header);
    } on MissingPluginException {
      final path = await _current;
      final fd = await File(path).open(mode: FileMode.writeOnlyAppend);
      await _writeLocked(fd, header);

      _fd = fd;
    }

    // configure our loggy handler to use the newly configured custom printer
    Loggy.initLoggy(logPrinter: LogUtils());

    // replacing this is sufficient to log FlutterError.onError messages because
    // it internally defers to this function
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message == null) {
        return;
      }
      log(ouisync.LogLevel.error, '$message\n');
    };

    // NOTE: if sentry is used, it will override these methods but still call
    // them after processing the events, so they are not lost
    PlatformDispatcher.instance.onError = (exception, stack) {
      final message = StringBuffer();
      message.writeln('Unhandled platform exception: ');
      message.writeln(exception);
      message.writeln(stack);
      log(ouisync.LogLevel.error, message.toString());
      return true;
    };
  }

  // write an atomic log entry to the default log target; this is either the
  // native channel (if implemented) or a file that we lock manually
  static void log(ouisync.LogLevel level, String message) {
    final fd = _fd;

    if (fd == null) {
      Native.log(level, message);
    } else {
      unawaited(
        Future(
          () => _writeLocked(
            fd,
            '${DateTime.now()} ${level.name.toUpperCase()} $message',
          ),
        ),
      );
    }
  }

  // LoggyPrinter implementation
  @override
  void onLog(LogRecord record) {
    // map loggy level to ouisync level (rust)
    final prio = record.level.priority;
    final level = prio < LogLevel.debug.priority
        ? ouisync.LogLevel.trace
        : prio < LogLevel.info.priority
            ? ouisync.LogLevel.debug
            : prio < LogLevel.warning.priority
                ? ouisync.LogLevel.info
                : prio < LogLevel.error.priority
                    ? ouisync.LogLevel.warn
                    : ouisync.LogLevel.error;

    // prepend logger name to message
    final message = StringBuffer();
    message.write(record.loggerName);
    message.write(' ');
    message.writeln(record.message);

    // if present, include error and stack trace in final message
    if (record.error != null) {
      message.writeln(record.error);
    }
    if (record.stackTrace != null) {
      message.writeln(record.stackTrace);
    }

    log(level, message.toString());
  }

  /// Path to the active log file; older logs are named $path.1, $path.2, etc.
  static Future<String> get _current async {
    final appDir = await Native.getBaseDir();
    final logDir = Directory(join(appDir.path, 'logs'));
    await logDir.create(recursive: true);

    return join(logDir.path, Constants.logFileName);
  }
}

/// Adds a getter for a (cached) loggy instance tagged with the name of the
/// class it's mixed into.
mixin AppLogger implements LoggyType {
  @override
  Loggy<AppLogger> get loggy => Loggy(runtimeType.toString());
}

/// Returns logger tagged with the given name. Useful for logging from static methods.
Loggy appLogger(String name) => Loggy(name);

Future<void> _writeLocked(RandomAccessFile fd, String data) async {
  await fd.lock();
  await fd.writeString(data);
  await fd.unlock();
}
