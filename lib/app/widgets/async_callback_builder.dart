import 'dart:async';

import 'package:flutter/material.dart';

typedef AsyncCallback = FutureOr<void> Function();

/// Wrapper around widgets that take callbacks (e.g., buttons) which adapts async callback into
/// non-async one while ensuring the callback is invoked only once at a time.
///
/// Example:
///
/// ```dart
/// Widget build(BuildContext context) => AsyncCallbackBuilder(
///     callback: () async {
///         print('start');
///         await Future.delayed(Duration(seconds: 1));
///         print('done');
///     },
///     builder: (context, callback) => TextButton(
///         onPressed: callback,
///         child: const Text('Press me'),
///     ),
/// );
/// ```
class AsyncCallbackBuilder extends StatefulWidget {
  final AsyncCallback? callback;
  final Widget Function(BuildContext context, VoidCallback? callback) builder;

  AsyncCallbackBuilder({
    required this.callback,
    required this.builder,
    super.key,
  });

  @override
  State<AsyncCallbackBuilder> createState() => _AsyncCallbackBuilderState();
}

class _AsyncCallbackBuilderState extends State<AsyncCallbackBuilder> {
  bool invoking = false;

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    widget.callback != null && !invoking ? _invoke : null,
  );

  void _invoke() {
    setState(() {
      invoking = true;
    });

    unawaited(
      Future.sync(() async {
        try {
          await widget.callback?.call();
        } finally {
          if (mounted) {
            setState(() {
              invoking = false;
            });
          }
        }
      }),
    );
  }
}
