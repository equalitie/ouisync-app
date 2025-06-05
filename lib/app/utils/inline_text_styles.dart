import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

class InlineTextStyles {
  InlineTextStyles._();

  static StyledTextTagBase bold =
      StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold));

  static StyledTextTagBase size({double size = 28.0}) =>
      StyledTextTag(style: TextStyle(fontSize: size));

  static StyledTextTagBase color(Color color) =>
      StyledTextTag(style: TextStyle(color: color));

  static StyledTextTagBase icon(IconData icon, {double? size, Color? color}) =>
      StyledTextIconTag(icon, size: size, color: color);
}
