import 'package:flutter/material.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';
import '../navigation_tile_mobile.dart';

class PlatformRenameTile extends PlatformWidget {
  PlatformRenameTile(
      {required this.reposCubit,
      required this.repoName,
      required this.title,
      required this.icon,
      required this.onRenameRepository});

  final ReposCubit reposCubit;
  final String repoName;
  final String title;
  final IconData icon;

  final Future<void> Function(BuildContext) onRenameRepository;

  @override
  Widget buildDesktopWidget(BuildContext context) => ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () async => await onRenameRepository(context));

  @override
  Widget buildMobileWidget(BuildContext context) => NavigationTileMobile(
      title: Text(title),
      leading: Icon(icon),
      onPressed: (context) async => await onRenameRepository(context));
}
