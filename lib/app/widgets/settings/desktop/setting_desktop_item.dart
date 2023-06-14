import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

import 'desktop_settings.dart';

class SettingDesktopItem extends StatelessWidget {
  const SettingDesktopItem(
      {required SettingItem item,
      this.leading,
      this.trailing,
      bool enabled = true,
      bool selected = false,
      required this.onTap})
      : _item = item,
        _selected = selected,
        _enabled = enabled;

  final SettingItem _item;
  final Widget? leading;
  final Widget? trailing;
  final bool _enabled;
  final bool _selected;
  final VoidCallback? onTap;

  String get name => _item.name;
  String? get description => _item.description;
  bool get enabled => _enabled;
  bool get selected => _selected;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(_item.name, style: _getStyle()),
        subtitle: _item.description != null
            ? Text(_item.description!, style: _getStyle())
            : null,
        leading: leading,
        trailing: trailing,
        enabled: _enabled,
        selected: _selected,
        onTap: onTap,
      );

  TextStyle _getStyle() {
    Color? color = Colors.black54;
    FontWeight fontWeight = FontWeight.normal;

    if (_selected) {
      color = Colors.black;
      fontWeight = FontWeight.w500;
    }

    return TextStyle(
        color: color, fontSize: Dimensions.fontSmall, fontWeight: fontWeight);
  }
}
