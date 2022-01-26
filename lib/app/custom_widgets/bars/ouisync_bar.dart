import 'package:flutter/material.dart';

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
      toolbarHeight: toolbarHeight,
      shadowColor: Colors.black26,
      leading: leadingAppBranding,
      title: titleCentralWidget,
      titleSpacing: 0.0,
      actions: actionList,
      bottom: PreferredSize(
        preferredSize: bottomPreferredSize,
        child: Container(
          color: Theme.of(context).primaryColor,
          child: bottomWidget
        ),
      ),
    );
  }

  @override
  Size get preferredSize => bottomPreferredSize;
}