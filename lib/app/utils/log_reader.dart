import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'ansi_parser.dart';
import 'log.dart';

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
  // TODO: on desktop the format is different
  static final _regexp =
      RegExp(r'(\d+-\d+-\d+\s\d+:\d+:\d+)\.\d*\s([EWIDV])\/[^:]*:(.*)');
}

/// Reader of messages from the system logger (logcat)
class LogReader {
  final Stream<LogMessage> messages;
  LogLevel filter;

  LogReader() : this._(LogUtils.watch);

  LogReader._(Stream<List<int>> input, {this.filter = LogLevel.verbose})
      : messages = input
            .asBroadcastStream()
            .map((chunk) => utf8.decode(chunk))
            .expand((chunk) => LogMessage.parse(chunk))
            .where((message) => message.level >= filter);
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
