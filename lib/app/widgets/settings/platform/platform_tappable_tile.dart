import 'package:flutter/material.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';
import '../navigation_tile_mobile.dart';

class PlatformTappableTile extends PlatformWidget {
  PlatformTappableTile(
      {required this.reposCubit,
      required this.repoName,
      required this.title,
      required this.icon,
      this.onTap});

  final ReposCubit reposCubit;
  final String repoName;
  final String title;
  final IconData icon;

  final dynamic Function(dynamic)? onTap;

  @override
  Widget buildDesktopWidget(BuildContext context) => ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () => onTap?.call(context));

  @override
  Widget buildMobileWidget(BuildContext context) => NavigationTileMobile(
      title: Text(title),
      leading: Icon(icon),
      onPressed: (context) => onTap?.call(context));
}
