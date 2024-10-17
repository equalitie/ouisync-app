import 'package:flutter/material.dart';

class DirectionalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DirectionalAppBar({
    this.textDirection = TextDirection.ltr,
    this.leading,
    this.title,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.titleSpacing,
    this.leadingWidth,
    this.titleTextStyle,
    super.key,
  });

  final TextDirection textDirection;
  final Widget? leading;
  final Widget? title;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? titleSpacing;
  final double? leadingWidth;
  final TextStyle? titleTextStyle;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: AppBar(
        leading: leading,
        title: title,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: actions,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        titleSpacing: titleSpacing,
        leadingWidth: leadingWidth,
        titleTextStyle: titleTextStyle,
        elevation: 0.0,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
