import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart' as s;

import '../../utils/platform/platform_values.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    this.leading,
    this.trailing,
    this.value,
    this.onTap,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PlatformValues.isMobileDevice
      ? _buildMobile(context)
      : _buildDesktop(context);

  Widget _buildMobile(BuildContext context) => s.SettingsTile(
        title: title,
        leading: leading,
        trailing: trailing,
        value: value,
        onPressed: onTap != null ? (_) => onTap!() : null,
      );

  Widget _buildDesktop(BuildContext context) => ListTile(
        title: title,
        leading: leading,
        trailing: trailing,
        subtitle: value,
        onTap: onTap,
      );
}

class SwitchSettingsTile extends StatelessWidget {
  const SwitchSettingsTile({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.leading,
    this.subtitle = null,
  });

  final bool value;
  final Widget title;
  final Widget? subtitle;
  final Widget leading;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => PlatformValues.isMobileDevice
      ? _buildMobile(context)
      : _buildDesktop(context);

  Widget _buildMobile(BuildContext context) => s.SettingsTile.switchTile(
        initialValue: value,
        title: title,
        leading: leading,
        onToggle: onChanged,
        description: subtitle,
      );

  Widget _buildDesktop(BuildContext context) => SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: title,
        subtitle: subtitle,
        secondary: leading,
      );
}

class NavigationTile extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? value;
  final VoidCallback? onTap;

  NavigationTile({
    required this.title,
    this.leading,
    Widget? trailing,
    this.value,
    this.onTap,
  }) : trailing = trailing ?? const Icon(Icons.navigate_next);

  @override
  Widget build(BuildContext context) => PlatformValues.isMobileDevice
      ? _buildMobile(context)
      : _buildDesktop(context);

  Widget _buildMobile(BuildContext context) => s.SettingsTile.navigation(
        title: title,
        leading: leading,
        trailing: trailing,
        value: value,
        onPressed: onTap != null ? (_) => onTap!() : null,
      );

  Widget _buildDesktop(BuildContext context) => ListTile(
        leading: leading,
        trailing: trailing,
        title: title,
        subtitle: value,
        onTap: onTap,
      );
}
