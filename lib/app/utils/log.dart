import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
class LogUtils {
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

  static Future<void> init() async {
    // our logs can contain data from multiple invocations, so to differentiate
    // we write this header every time the app starts
    final package = await PackageInfo.fromPlatform();
    final baseDir = await Native.getBaseDir();
    final header = '''
-------------------- ${package.appName} Start --------------------
version:  ${package.version} $appFlavor (build ${package.buildNumber})
started:  ${_formatTimestamp(DateTime.now())}
platform: ${Platform.operatingSystemVersion}
baseDir:  ${baseDir.path}
${'-' * (48 + package.appName.length)}''';

    LoggyPrinter defaultPrinter;

    // Log to platform's default logging facility
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      defaultPrinter = _NativePrinter();
    } else {
      defaultPrinter = _ConsolePrinter();
    }

    // Log also to file
    final filePrinter = _FilePrinter(await _current);

    // configure our loggy handler to use the newly configured custom printer
    Loggy.initLoggy(logPrinter: _FanoutPrinter(defaultPrinter, filePrinter));

    final logger = appLogger('');

    FlutterError.onError = (details) {
      logger.error(
        'Unhandled flutter exception: ',
        details.exception,
        details.stack,
      );

      FlutterError.presentError(details);
    };

    // NOTE: if sentry is used, it will override these methods but still call
    // them after processing the events, so they are not lost
    PlatformDispatcher.instance.onError = (exception, stack) {
      logger.error('Unhandled platform exception: ', exception, stack);
      return true;
    };

    logger.info(header);
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

/// Path to the active log file; older logs are named $path.1, $path.2, etc.
Future<String> get _current async {
  final appDir = await Native.getBaseDir();
  final logDir = Directory(join(appDir.path, 'logs'));
  await logDir.create(recursive: true);

  return join(logDir.path, Constants.logFileName);
}

class _FilePrinter extends LoggyPrinter {
  final IOSink _sink;

  _FilePrinter(String path)
      : _sink = File(path).openWrite(mode: FileMode.append);

  @override
  void onLog(LogRecord record) {
    _sink.writeln(_formatRecord(record));
  }
}

class _NativePrinter extends LoggyPrinter {
  @override
  void onLog(LogRecord record) {
    final level = record.level.toOuisync();
    final message = _formatMessage(record);

    Native.log(level, message);
  }
}

class _ConsolePrinter extends LoggyPrinter {
  @override
  void onLog(LogRecord record) {
    stdout.writeln(_formatRecord(record));
  }
}

// Printer that forwards the log records to two other printers.
class _FanoutPrinter extends LoggyPrinter {
  final LoggyPrinter a;
  final LoggyPrinter b;

  _FanoutPrinter(this.a, this.b);

  @override
  void onLog(LogRecord record) {
    a.onLog(record);
    b.onLog(record);
  }
}

final _levelPad =
    ouisync.LogLevel.values.map((level) => level.name.length).reduce(max);

String _formatRecord(LogRecord record) {
  final level = record.level.toOuisync();
  final message = _formatMessage(record);
  return '${_formatTimestamp(DateTime.now())} ${level.name.toUpperCase().padRight(_levelPad)} $message';
}

String _formatMessage(LogRecord record) {
  // prepend logger name to message
  final buffer = StringBuffer();

  if (record.loggerName.isNotEmpty) {
    buffer.write(record.loggerName);
    buffer.write(' ');
  }

  buffer.write(record.message);

  // if present, include error and stack trace in final message
  if (record.error != null) {
    buffer.write(record.error);
  }

  if (record.stackTrace != null && record.stackTrace != StackTrace.empty) {
    buffer.writeln();
    buffer.write(record.stackTrace);
  }

  return buffer.toString();
}

String _formatTimestamp(DateTime timestamp) =>
    timestamp.toUtc().toIso8601String();

const trace = LogLevel('Trace', 1);

extension LoggyLogLevelExtension on LogLevel {
  ouisync.LogLevel toOuisync() => switch (this) {
        LogLevel.error => ouisync.LogLevel.error,
        LogLevel.warning => ouisync.LogLevel.warn,
        LogLevel.info => ouisync.LogLevel.info,
        LogLevel.debug => ouisync.LogLevel.debug,
        trace => ouisync.LogLevel.trace,
        _ => ouisync.LogLevel.trace,
      };
}

extension OuisyncLogLevelExtension on ouisync.LogLevel {
  LogLevel toLoggy() => switch (this) {
        ouisync.LogLevel.error => LogLevel.error,
        ouisync.LogLevel.warn => LogLevel.warning,
        ouisync.LogLevel.info => LogLevel.info,
        ouisync.LogLevel.debug => LogLevel.debug,
        ouisync.LogLevel.trace => trace,
      };
}
