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
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    alignment: Alignment.topCenter,
                    child: content,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: footer,
                  ),
                ],
              ),
            ),
          );
        },
      );
}
