import 'package:flutter/material.dart';

import 'desktop_settings.dart';

class RepositoryDesktopDetail extends StatelessWidget {
  const RepositoryDesktopDetail({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.yellow, child: Text(item.name))))
    ]);
  }
}
