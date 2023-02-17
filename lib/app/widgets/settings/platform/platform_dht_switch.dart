import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';

class PlatformDhtSwitch extends PlatformWidget {
  PlatformDhtSwitch(
      {required this.repository, required this.title, required this.icon});

  final RepoCubit repository;
  final String title;
  final IconData icon;

  @override
  Widget buildDesktopWidget(BuildContext context) => SwitchListTile.adaptive(
        value: repository.isDhtEnabled,
        title: Text(title),
        secondary: Icon(icon),
        onChanged: (value) => repository.setDhtEnabled(value),
      );

  @override
  Widget buildMobileWidget(BuildContext context) => SettingsTile.switchTile(
        initialValue: repository.isDhtEnabled,
        title: Text(title),
        leading: Icon(icon),
        onToggle: (value) => repository.setDhtEnabled(value),
      );
}
