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
    return Text(
      folderData.name,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: Dimensions.fontAverage,
      ),
    );
  }
}
