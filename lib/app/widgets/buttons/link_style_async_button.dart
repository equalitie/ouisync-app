import 'package:flutter/material.dart';
import 'dart:async';

class LinkStyleAsyncButton extends StatefulWidget {
  LinkStyleAsyncButton({super.key, required this.text, this.onTap});

  final String text;
  final Future<void> Function()? onTap;

  @override
  State<LinkStyleAsyncButton> createState() => _State();
}

class _State extends State<LinkStyleAsyncButton> {
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    final asyncOnPressed = widget.onTap;
    final enabled = (asyncOnPressed != null && isRunning == false);

    final onTap = enabled
        ? () {
            unawaited(() async {
              setState(() {
                isRunning = true;
              });
              try {
                await asyncOnPressed();
              } finally {
                setState(() {
                  isRunning = false;
                });
              }
            }());
          }
        : null;

    return InkWell(
      child: RichText(
        text: TextSpan(
          text: widget.text,
          style: TextStyle(color: Colors.blue),
        ),
      ),
      onTap: onTap,
    );
  }
}
