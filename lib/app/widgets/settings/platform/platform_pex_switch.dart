import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';
import '../../../utils/utils.dart';

class PlatformPexSwitch extends StatelessWidget {
  const PlatformPexSwitch(
      {required this.repository,
      required this.title,
      required this.icon,
      required this.onToggle});

  final RepoCubit repository;
  final String title;
  final IconData icon;

  final dynamic Function(bool)? onToggle;

  @override
  Widget build(BuildContext context) {
    if (PlatformValues.isMobileDevice) {
      return buildMobileWidget(context);
    }
    return buildDesktopWidget(context);
  }

  Widget buildDesktopWidget(BuildContext context) => SwitchListTile.adaptive(
      value: repository.state.isPexEnabled,
      title: Text(title, style: TextStyle(fontSize: Dimensions.fontSmall)),
      secondary: Icon(icon),
      onChanged: (value) => onToggle?.call(value));

  AbstractSettingsTile buildMobileWidget(BuildContext context) =>
      SettingsTile.switchTile(
          initialValue: repository.state.isPexEnabled,
          title: Text(title),
          leading: Icon(icon),
          onToggle: (value) => onToggle?.call(value));
}
