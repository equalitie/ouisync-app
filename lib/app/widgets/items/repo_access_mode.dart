import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../utils/utils.dart';

class RepoAccessMode extends StatelessWidget {
  RepoAccessMode({
    required this.accessMode,
    required this.onTap,
    Key? key
  }) : super(key: key);

  final AccessMode accessMode;
  final Function() onTap;
  final ValueNotifier<bool> _isSelected = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ValueListenableBuilder(
            valueListenable: _isSelected, 
            builder: (context, isSelected, child) {
              return Icon(isSelected as bool
                ? Icons.check : null);
            }),
          Fields.constrainedText(accessMode.name.capitalize())
        ],
      ));
  }
}
