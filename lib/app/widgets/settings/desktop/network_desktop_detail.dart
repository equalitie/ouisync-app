import 'package:flutter/material.dart';

import 'desktop_settings.dart';

class NetworkDesktopDetail extends StatelessWidget {
  const NetworkDesktopDetail({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.red, child: Text(item.name))))
    ]);
  }
}
