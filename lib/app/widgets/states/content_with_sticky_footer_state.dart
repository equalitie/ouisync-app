import 'package:flutter/material.dart';

class ContentWithStickyFooterState extends StatelessWidget {
  const ContentWithStickyFooterState({
    required this.content,
    required this.footer,
  });

  final Widget content;
  final Widget footer;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:
        (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 18.0),
                  alignment: AlignmentDirectional.topCenter,
                  child: content,
                ),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(vertical: 18.0),
                  child: SafeArea(child: footer),
                ),
              ],
            ),
          ),
        ),
  );
}
