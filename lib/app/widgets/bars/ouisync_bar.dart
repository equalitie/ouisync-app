import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

class OuiSyncBar extends StatelessWidget with PreferredSizeWidget {
  OuiSyncBar({
    required this.repoList,
    required this.actionList,
    required this.bottomWidget,
  });

  final Widget repoList;
  final List<Widget> actionList;
  final PreferredSizeWidget bottomWidget;
  // TODO: Can we get this from the `repoList` widget?
  final double toolbarHeight = 60;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolbarHeight,
      shadowColor: Colors.black26,
      title: repoList,
      // Make the `repoList` have no spacing on the horizontal axis.
      titleSpacing: 0.0,
      actions: actionList,
      bottom: bottomWidget,
    );
  }

  @override
  Size get preferredSize => Size(
      bottomWidget.preferredSize.width,
      bottomWidget.preferredSize.height + toolbarHeight);
}
