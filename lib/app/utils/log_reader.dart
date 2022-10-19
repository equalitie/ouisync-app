import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:convert';

import 'ansi_parser.dart';

enum LogLevel {
  error,
  warn,
  info,
  debug,
  verbose,
}

LogLevel _parseLogLevel(String input) {
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

class LogMessage {
  final DateTime timestamp;
  final LogLevel level;
  final String content;

  LogMessage({
    required this.timestamp,
    required this.level,
    required this.content,
  });

  static Iterable<LogMessage> parse(String input) =>
      _regexp.allMatches(input).map((match) {
        final timestamp = DateTime.tryParse(match.group(1)!) ?? DateTime.now();
        final level = _parseLogLevel(match.group(2)!);
        final content = removeAnsi(match.group(3)!);

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
  final Stream<LogMessage> _messages;

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

    final messages = logcat.stdout
        .map((line) => utf8.decode(line))
        .expand((line) => LogMessage.parse(line));

    return LogReader._(logcat, messages);
  }

  LogReader._(this._logcat, this._messages);

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
