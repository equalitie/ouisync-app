import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:convert';

import 'ansi_parser.dart';

enum LogLevel {
  verbose,
  debug,
  info,
  warn,
  error;

  bool operator <(LogLevel other) => index < other.index;
  bool operator >(LogLevel other) => index > other.index;
  bool operator <=(LogLevel other) => index <= other.index;
  bool operator >=(LogLevel other) => index >= other.index;

  static LogLevel parse(String input) {
    switch (input.trim().toUpperCase()) {
      case 'E':
        return LogLevel.error;
      case 'W':
        return LogLevel.warn;
      case 'I':
        return LogLevel.info;
      case 'D':
        return LogLevel.debug;
      case 'V':
        return LogLevel.verbose;
      default:
        return LogLevel.verbose;
    }
  }

  String toShortString() => name[0].toUpperCase();
}

class LogMessage {
  final DateTime timestamp;
  final LogLevel level;
  final List<AnsiSpan> content;

  LogMessage({
    required this.timestamp,
    required this.level,
    required this.content,
  });

  static Iterable<LogMessage> parse(String input) =>
      _regexp.allMatches(input).map((match) {
        final timestamp = DateTime.tryParse(match.group(1)!) ?? DateTime.now();
        final level = LogLevel.parse(match.group(2)!);
        final content = parseAnsi(match.group(3)!).toList();

        return LogMessage(
          timestamp: timestamp,
          level: level,
          content: content,
        );
      });

  // The log messages have this format:
  //
  // 2022-10-19 09:52:00.079 D/flutter-ouisync( 7653):  2022-10-19T07:52:00.079Z  INFO  DHT IPv6 bootstrap complete
  // <----------+----------> | <---------+---------->   <------------------+-------------------------------------->
  //            |            |           |                                 |
  //            timestamp    |           tag and PID (ignored)             content
  //                         log level
  //
  static final _regexp =
      RegExp(r'(\d+-\d+-\d+\s\d+:\d+:\d+)\.\d*\s([EWIDV])\/[^:]*:(.*)');
}

/// Reader of messages from the system logger (logcat)
class LogReader {
  final Process _logcat;
  late final Stream<LogMessage> _messages;
  LogLevel filter = LogLevel.verbose;

  static Future<LogReader> open() async {
    final logcat = await Process.start(
      'logcat',
      [
        '-vtime',
        '-vyear',
        '*:S',
        'flutter:V',
        'flutter-ouisync:V',
      ],
    );

    return LogReader._(logcat);
  }

  LogReader._(this._logcat) {
    _messages = _logcat.stdout
        .asBroadcastStream()
        .map((line) => utf8.decode(line))
        .expand((line) => LogMessage.parse(line))
        .where((message) => message.level >= filter);
  }

  Stream<LogMessage> get messages => _messages;

  void close() {
    _logcat.kill();
  }
}

/// Rolling window of the most recent log messages
class LogBuffer {
  final _buffer = ListQueue<LogMessage>();
  int _capacity = 64;

  LogBuffer();

  int get capacity => _capacity;

  set capacity(value) {
    _capacity = value;

    while (_buffer.length > _capacity) {
      _buffer.removeFirst();
    }
  }

  int get length => _buffer.length;

  LogMessage operator [](int index) => _buffer.elementAt(index);

  void add(LogMessage message) {
    while (_buffer.length >= _capacity) {
      _buffer.removeFirst();
    }

    _buffer.addLast(message);
  }
}
