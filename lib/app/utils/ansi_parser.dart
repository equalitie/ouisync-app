/// Simple parser for ANSI color sequences

import 'dart:ui';

import 'package:flutter/material.dart';

class RawAnsiSpan {
  final String text;
  final List<int> codes;

  RawAnsiSpan(this.text, this.codes);
}

Iterable<TextSpan> parseAnsi(String input) sync* {
  final styleBuilder = _StyleBuilder();

  for (final span in parseAnsiRaw(input)) {
    final style = styleBuilder.interpret(span.codes);

    yield TextSpan(
      text: span.text,
      style: style,
    );
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
  Color? foreground;
  Color? background;
  FontWeight fontWeight = FontWeight.normal;
  FontStyle fontStyle = FontStyle.normal;

  _StyleBuilder();

  TextStyle interpret(List<int> codes) {
    for (final code in codes) {
      if (code == 0) {
        foreground = null;
        background = null;
        fontWeight = FontWeight.normal;
        fontStyle = FontStyle.normal;
      }

      if (code == 1) {
        fontWeight = FontWeight.w500;
        continue;
      }

      if (code == 2) {
        fontWeight = FontWeight.w300;
        continue;
      }

      if (code == 3) {
        fontStyle = FontStyle.italic;
      }

      if (code >= 30 && code <= 37) {
        foreground = _palette[code - 30];
        continue;
      }

      if (code == 39) {
        foreground = null;
        continue;
      }

      if (code >= 40 && code <= 47) {
        background = _palette[code - 40];
        continue;
      }

      if (code == 49) {
        background = null;
        continue;
      }
    }

    return TextStyle(
      color: foreground,
      backgroundColor: background,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

final _palette = <int, Color>{
  0: Colors.black,
  1: Colors.red,
  2: Colors.green,
  3: Colors.yellow,
  4: Colors.blue,
  5: Colors.purple,
  6: Colors.cyan,
  7: Colors.grey.shade600,
};
