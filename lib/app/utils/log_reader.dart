import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'ansi_parser.dart';
import 'log.dart' as log;

class LogMessage {
  final List<AnsiSpan> content;

  LogMessage(this.content);

  static LogMessage parse(String input) =>
      LogMessage(parseAnsi(input).toList());
}

/// Reader of messages from the system logger (logcat)
class LogReader {
  final Stream<LogMessage> messages;

  LogReader()
    : messages = log.watch
          .asBroadcastStream()
          .map((chunk) => utf8.decode(chunk))
          .map((chunk) => LogMessage.parse(chunk));
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
