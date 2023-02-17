import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';

class PlatformSwitch extends PlatformWidget {
  PlatformSwitch(
      {required this.repository,
      required this.title,
      required this.icon,
      required this.onToggle});

  final RepoCubit repository;
  final String title;
  final IconData icon;

  final dynamic Function(bool)? onToggle;

  @override
  Widget buildDesktopWidget(BuildContext context) => SwitchListTile.adaptive(
      value: repository.isDhtEnabled,
      title: Text(title),
      secondary: Icon(icon),
      onChanged: onToggle);

  @override
  Widget buildMobileWidget(BuildContext context) => SettingsTile.switchTile(
      initialValue: repository.isDhtEnabled,
      title: Text(title),
      leading: Icon(icon),
      onToggle: onToggle);
}
