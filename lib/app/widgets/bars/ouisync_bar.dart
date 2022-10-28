import 'package:flutter/material.dart';
import 'package:ouisync_app/flavors.dart';

class OuiSyncBar extends StatelessWidget with PreferredSizeWidget {
  OuiSyncBar({
    required this.repoList,
    required this.settingsButton,
  });

  final PreferredSizeWidget repoList;
  final Widget settingsButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.black26,
      title: repoList,
      // Make the `repoList` have no spacing on the horizontal axis.
      titleSpacing: 0.0,
      actions: [settingsButton],
      backgroundColor: F.color,
    );
  }

  @override
  Size get preferredSize =>
      Size(repoList.preferredSize.width, repoList.preferredSize.height);
}
