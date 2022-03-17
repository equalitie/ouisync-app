import 'package:flutter/widgets.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class FolderDescription extends StatelessWidget {
  const FolderDescription({
    required this.folderData,
  });

  final BaseItem folderData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getUI(),
      ),
    );
  }

  List<Widget> _getUI() {
    return [
      Text(
        folderData.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: Dimensions.fontAverage,
        ),
      ),
    ];
  }
}