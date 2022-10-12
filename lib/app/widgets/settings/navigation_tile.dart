import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class NavigationTile extends AbstractSettingsTile {
  final Widget title;
  final Widget? leading;
  final Widget? value;
  final dynamic Function(BuildContext)? onPressed;
  final bool enabled;

  NavigationTile({
    required this.title,
    this.leading,
    this.value,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => SettingsTile.navigation(
      title: title,
      leading: leading,
      trailing: Icon(Icons.navigate_next),
      value: value,
      onPressed: onPressed,
      enabled: enabled);
}
