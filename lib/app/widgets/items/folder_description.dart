import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class FolderDescription extends StatelessWidget {
  const FolderDescription({
    required this.folderData,
  });

  final BaseItem folderData;

  @override
  Widget build(BuildContext context) => Fields.ellipsedText(
        folderData.name,
        ellipsisPosition: TextOverflowPosition.middle,
      );
}
