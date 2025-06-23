import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import 'package:logtee/logtee.dart';
import 'package:ouisync/ouisync.dart' as ouisync;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';

import 'constants.dart';
import 'dirs.dart';
import 'flavor.dart';
import 'native.dart';

File? _file;
Logtee? _tee;

Future<void> init(Dirs dirs) async {
  final file = File(join(dirs.root, 'logs', Constants.logFileName));
  _file = file;

  // our logs can contain data from multiple invocations, so to differentiate
  // we write this header every time the app starts
  final package = await PackageInfo.fromPlatform();
  final header = '''
-------------------- ${package.appName} Start --------------------
version:  ${package.version} ${Flavor.current} (build ${package.buildNumber})
started:  ${_formatTimestamp(DateTime.now())}
platform: ${Platform.operatingSystemVersion}
root dir: ${dirs.root}
log file: ${file.path}
${'-' * (48 + package.appName.length)}''';

  _tee = Logtee.start(file.path);

  LoggyPrinter defaultPrinter;

  // Log to platform's default logging facility
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    defaultPrinter = _NativePrinter();
  } else {
    defaultPrinter = _ConsolePrinter();
  }

  // configure our loggy handler to use the newly configured custom printer
  Loggy.initLoggy(logPrinter: defaultPrinter);

  final logger = named('');

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

void shutdown() {
  _tee?.stop();
  _tee = null;
}

/// Dump all logs from the log folder to the given sink
Future<void> dump(IOSink sink) async {
  final file = _file;
  if (file == null) {
    return;
  }

  final all =
      await file.parent
          .list()
          .map((entry) => entry.absolute.path)
          .where((path) => path.startsWith(file.path))
          .toList();

  // The logs files are named 'ouisync.log', 'ouisync.log.1', 'ouisync.log.2',
  // etc. so sorting them in reverse lexigographical order yields them from
  // the oldest to the newest. FIXME: what about 'ouisync.log.10'?
  all.sort((a, b) => b.compareTo(a));

  for (final path in all) {
    await sink.addStream(File(path).openRead());
  }
}

/// Watch the log file for changes.
Stream<List<int>> get watch async* {
  final file = _file;
  if (file == null) {
    return;
  }

  int offset = 0;

  // open `file` and tail (unix) from `offset` to eof, updating `offset` in
  // the process.
  Stream<List<int>> tail() => file.openRead(offset).map((chunk) {
    offset += chunk.length;
    return chunk;
  });

  yield* tail(); // first yield the whole file as is right now then...

  // watch for changes
  await for (final _ in file.watch()) {
    yield* tail(); // ...and yield them as they come
  }
}

/// Adds a getter for a (cached) loggy instance tagged with the name of the
/// class it's mixed into.
mixin AppLogger implements LoggyType {
  @override
  Loggy<AppLogger> get loggy => Loggy(runtimeType.toString());
}

/// Returns logger tagged with the given name. Useful for logging from static methods or free
/// functions. Otherwise prefer to use the `AppLogger` mixin.
Loggy named(String name) => Loggy(name);

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
    // ignore: avoid_print
    print(_formatRecord(record));
  }
}

final _levelPad = ouisync.LogLevel.values
    .map((level) => level.name.length)
    .reduce(max);

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
