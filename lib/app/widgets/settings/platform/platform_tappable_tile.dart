import 'package:flutter/material.dart';

import '../../../utils/platform/platform.dart';
import '../navigation_tile_mobile.dart';

class PlatformTappableTile extends PlatformWidget {
  PlatformTappableTile({required this.title, this.icon, this.onTap});

  final Widget title;
  final IconData? icon;

  final dynamic Function(dynamic)? onTap;

  @override
  Widget buildDesktopWidget(BuildContext context) => ListTile(
      leading: Icon(icon), title: title, onTap: () => onTap?.call(context));

  @override
  Widget buildMobileWidget(BuildContext context) => NavigationTileMobile(
      leading: Icon(icon),
      title: title,
      onPressed: (context) => onTap?.call(context));
}
