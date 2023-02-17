import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';

class PlatformPeerExchangeSwitch extends PlatformWidget {
  PlatformPeerExchangeSwitch(
      {required this.repository, required this.title, required this.icon});

  final RepoCubit repository;
  final String title;
  final IconData icon;

  @override
  Widget buildDesktopWidget(BuildContext context) => SwitchListTile.adaptive(
        value: repository.isPexEnabled,
        title: Text(title),
        secondary: Icon(icon),
        onChanged: (value) => repository.setPexEnabled(value),
      );

  @override
  Widget buildMobileWidget(BuildContext context) => SettingsTile.switchTile(
        initialValue: repository.isPexEnabled,
        title: Text(title),
        leading: Icon(icon),
        onToggle: (value) => repository.setPexEnabled(value),
      );
}
