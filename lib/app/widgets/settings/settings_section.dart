import 'package:flutter/material.dart';

abstract class SettingsSection {
  final GlobalKey key;
  final String title;

  const SettingsSection({required this.key, required this.title});

  List<Widget> buildTiles(BuildContext context);

  bool containsErrorNotification() => false;
  bool containsWarningNotification() => false;
}
