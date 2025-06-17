// Simple parser for ANSI color sequences
import 'dart:ui';

import 'package:flutter/material.dart';

class AnsiSpan {
  final String text;
  final AnsiStyle style;

  AnsiSpan({required this.text, required this.style});
}

class RawAnsiSpan {
  final String text;
  final List<int> codes;

  RawAnsiSpan(this.text, this.codes);
}

Iterable<AnsiSpan> parseAnsi(String input) sync* {
  final styleBuilder = _StyleBuilder();

  for (final span in parseAnsiRaw(input)) {
    final style = styleBuilder.interpret(span.codes);

    yield AnsiSpan(text: span.text, style: style);
  }
}

String removeAnsi(String input) =>
    parseAnsiRaw(input).map((span) => span.text).join();

Iterable<RawAnsiSpan> parseAnsiRaw(String input) sync* {
  final matches = _regexp.allMatches(input);
  int offset = 0;
  List<int> codes = [];

  for (final match in matches) {
    final text = input.substring(offset, match.start);
    if (text.isNotEmpty) {
      yield RawAnsiSpan(text, codes);
      codes = [];
    }

    codes.addAll(_parseCodes(match.group(1)!));
    offset = match.end;
  }

  yield RawAnsiSpan(input.substring(offset), codes);
}

final _regexp = RegExp(r'\u001b\[(\d+(:?;\d+)*)m');

List<int> _parseCodes(String input) =>
    input.trim().split(';').map((chunk) => int.tryParse(chunk) ?? 0).toList();

class _StyleBuilder {
  AnsiStyle _style = AnsiStyle();

  _StyleBuilder();

  AnsiStyle interpret(List<int> codes) {
    for (final code in codes) {
      if (code == 0) {
        _style = AnsiStyle();
      }

      if (code == 1) {
        _style.fontWeight = FontWeight.w500;
        continue;
      }

      if (code == 2) {
        _style.fontWeight = FontWeight.w300;
        continue;
      }

      if (code == 3) {
        _style.fontStyle = FontStyle.italic;
      }

      if (code >= 30 && code <= 37) {
        _style.foreground = AnsiColor.values[code - 30];
        continue;
      }

      if (code == 39) {
        _style.foreground = null;
        continue;
      }

      if (code >= 40 && code <= 47) {
        _style.background = AnsiColor.values[code - 40];
        continue;
      }

      if (code == 49) {
        _style.background = null;
        continue;
      }
    }

    return _style;
  }
}

enum AnsiColor { black, red, green, yellow, blue, magenta, cyan, white }

class AnsiStyle {
  AnsiColor? foreground;
  AnsiColor? background;
  FontWeight fontWeight;
  FontStyle fontStyle;

  AnsiStyle({
    this.foreground,
    this.background,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
  });
}
