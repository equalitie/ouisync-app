import 'package:flutter/material.dart';

import '../../models/models.dart';

class FolderDescription extends StatelessWidget {
  const FolderDescription({
    required this.folderData,
  });

  final BaseItem folderData;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Text(
      folderData.name,
      style: bodyStyle?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
