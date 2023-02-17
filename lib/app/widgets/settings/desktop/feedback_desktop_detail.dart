import 'package:flutter/material.dart';

import 'desktop_settings.dart';

class FeedbackDesktopDetail extends StatelessWidget {
  const FeedbackDesktopDetail({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.green, child: Text(item.name))))
    ]);
  }
}
