import 'package:flutter/material.dart';

import 'desktop_settings.dart';

class LogsDesktopDetail extends StatelessWidget {
  const LogsDesktopDetail({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.blue, child: Text(item.name))))
    ]);
  }
}
