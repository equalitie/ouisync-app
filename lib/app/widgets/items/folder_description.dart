import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

import '../../models/models.dart';

class FolderDescription extends StatelessWidget {
  const FolderDescription({
    required this.folderData,
  });

  final BaseItem folderData;

  @override
  Widget build(BuildContext context) => Fields.autosizeText(folderData.name,
      minFontSize: context.theme.appTextStyle.bodyMicro.fontSize,
      maxFontSize: context.theme.appTextStyle.bodyMedium.fontSize,
      maxLines: 2);
}
