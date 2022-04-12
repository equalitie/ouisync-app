import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

class OuiSyncBar extends StatelessWidget with PreferredSizeWidget {
  OuiSyncBar({
    required this.repoList,
    required this.actionList,
    required this.bottomWidget,
  });

  final PreferredSizeWidget repoList;
  final List<Widget> actionList;
  final PreferredSizeWidget bottomWidget;

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
      bottomWidget.preferredSize.width  + repoList.preferredSize.width,
      bottomWidget.preferredSize.height + repoList.preferredSize.height);
}
