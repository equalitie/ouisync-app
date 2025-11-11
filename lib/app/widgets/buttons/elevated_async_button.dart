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
  ElevatedAsyncButton({
    super.key,
    required this.child,
    this.style,
    this.onPressed,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<ElevatedAsyncButton> createState() => ElevatedAsyncButtonState();
}

class ElevatedAsyncButtonState extends State<ElevatedAsyncButton> {
  bool isExecuting = false;
  int execCounter = 0;

  ElevatedAsyncButtonState();

  @override
  Widget build(BuildContext context) {
    final callback = widget.onPressed;

    final onPressed = callback != null && isExecuting == false
        ? () => unawaited(_onPressed(callback))
        : null;

    return ElevatedButton(
      onPressed: onPressed,
      child: widget.child,
      style: widget.style,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
    );
  }

  Future<void> _onPressed(Future<void> Function() callback) async {
    setState(() {
      isExecuting = true;
    });

    try {
      await callback();
    } finally {
      if (mounted) {
        setState(() {
          isExecuting = false;
          ++execCounter;
        });
      }
    }
  }
}
