import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OuiSyncBar extends StatelessWidget with PreferredSizeWidget {
  OuiSyncBar({
    required this.appBranding,
    required this.defaultRepository,
    required this.centralWidget,
    required this.actions,
    required this.bottom,
    required this.mode, // Modes: full (includes branding), compact (no branding)
    required this.toolbarHeight,
    required this.preferredSize
  });

  final Widget appBranding;
  final String defaultRepository;
  final Widget centralWidget;
  final List<Widget> actions;
  final Widget bottom;
  final BarMode mode;
  final double toolbarHeight;
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolbarHeight,
      shadowColor: Colors.transparent,
      leading: appBranding,
      leadingWidth: 140.0,
      title: centralWidget,
      centerTitle: true,
      actions: actions,
      bottom: 
      PreferredSize(
        preferredSize: preferredSize,
        child: Container(
          color: Colors.white,
          child: bottom
        ),
      ),
    );
  }
}

enum BarMode {
  full,
  compact
}