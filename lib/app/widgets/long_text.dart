import 'package:flutter/material.dart';

/// Text that shows ellipsis on overflow but that has a tooltip with the full content.
class LongText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const LongText(this.text, {this.style});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: text,
    triggerMode: TooltipTriggerMode.tap,
    child: Text(text, overflow: TextOverflow.ellipsis, style: style),
  );
}
