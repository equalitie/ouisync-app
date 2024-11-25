import 'dart:async';
import 'package:flutter/material.dart';

class ElevatedAsyncButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final ButtonStyle? style;
  final Widget child;
  final bool autofocus;
  final FocusNode? focusNode;

  // When adding arguments, for consistency, they should be the same as the one
  // in `ElevatedButton`.
  ElevatedAsyncButton(
      {super.key,
      required this.child,
      this.style,
      this.onPressed,
      this.autofocus = false,
      this.focusNode});

  @override
  State<ElevatedAsyncButton> createState() => ElevatedAsyncButtonState();
}

class ElevatedAsyncButtonState extends State<ElevatedAsyncButton> {
  bool isExecuting = false;

  ElevatedAsyncButtonState();

  @override
  Widget build(BuildContext context) {
    final widgetOnPressed = widget.onPressed;

    final onPressed = widgetOnPressed != null && isExecuting == false
        ? () {
            setState(() {
              isExecuting = true;
            });
            unawaited(widgetOnPressed().whenComplete(() {
              setState(() {
                isExecuting = false;
              });
            }));
          }
        : null;

    return ElevatedButton(
        onPressed: onPressed,
        child: widget.child,
        style: widget.style,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode);
  }
}
