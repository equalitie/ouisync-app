import 'package:flutter/material.dart';

abstract class SettingsSection {
  final String title;
  // If provided, rebuilds the tiles on event from this stream.
  final Stream? changed;

  const SettingsSection({required this.title, this.changed});

  List<Widget> buildTiles(BuildContext context);

  bool containsErrorNotification() => false;
  bool containsWarningNotification() => false;
}
