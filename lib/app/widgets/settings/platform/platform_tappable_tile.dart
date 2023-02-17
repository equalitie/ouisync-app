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

  final Future<void> Function(BuildContext)? onTap;

  @override
  Widget buildDesktopWidget(BuildContext context) => ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: onTap != null ? const Icon(Icons.keyboard_arrow_right) : null,
      onTap: onTap != null ? () async => await onTap!(context) : null);

  @override
  Widget buildMobileWidget(BuildContext context) => NavigationTileMobile(
      title: Text(title),
      leading: Icon(icon),
      onPressed:
          onTap != null ? (context) async => await onTap!(context) : null);
}
