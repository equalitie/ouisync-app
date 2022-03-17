import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

class OuiSyncBar extends StatelessWidget with PreferredSizeWidget {
  OuiSyncBar({
    required this.leadingAppBranding,
    required this.titleCentralWidget,
    required this.actionList,
    required this.bottomWidget,
    required this.bottomPreferredSize,
    required this.toolbarHeight,
  });

  final Widget? leadingAppBranding;
  final Widget? titleCentralWidget;
  final List<Widget> actionList;
  final Widget bottomWidget;
  final Size bottomPreferredSize;
  final double toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: toolbarHeight,
      shadowColor: Colors.black26,
      leading: leadingAppBranding,
      title: titleCentralWidget,
      titleSpacing: Dimensions.spacingAppBarTitle,
      actions: actionList,
      bottom: PreferredSize(
        preferredSize: bottomPreferredSize,
        child: bottomWidget,
      ),
    );
  }

  @override
  Size get preferredSize => bottomPreferredSize;
}
