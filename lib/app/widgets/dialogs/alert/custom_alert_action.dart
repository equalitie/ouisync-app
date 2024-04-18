import 'package:flutter/material.dart';

class CustomAlertAction extends StatelessWidget {
  const CustomAlertAction({
    required this.parentContext,
    required this.text,
  });

  final BuildContext parentContext;
  final String text;

  @override
  Widget build(BuildContext context) => TextButton(
        child: Text(text.toUpperCase()),
        onPressed: () => Navigator.of(
          parentContext,
          rootNavigator: true,
        ).pop(false),
      );
}
