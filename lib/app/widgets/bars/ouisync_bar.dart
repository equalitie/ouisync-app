import 'package:flutter/material.dart';

class OuiSyncBar extends StatelessWidget with PreferredSizeWidget {
  OuiSyncBar({
    required this.repoPicker,
    required this.settingsButton,
  });

  final PreferredSizeWidget repoPicker;
  final Widget settingsButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        shadowColor: Colors.black26,
        title: repoPicker,
        // Make the `repoList` have no spacing on the horizontal axis.
        titleSpacing: 0.0,
        actions: [settingsButton]);
  }

  @override
  Size get preferredSize =>
      Size(repoPicker.preferredSize.width, repoPicker.preferredSize.height);
}
