import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class RepoDescription extends StatelessWidget with OuiSyncAppLogger {
  RepoDescription({required this.repoData});

  final RepoItem repoData;

  @override
  Widget build(BuildContext context) {
    final fontWeight = repoData.isDefault ? FontWeight.bold : FontWeight.normal;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.autosizeText(repoData.name, fontWeight: fontWeight),
          Fields.autosizeText(repoData.accessMode.name,
              fontSize: Dimensions.fontSmall, fontWeight: fontWeight)
        ],
      ),
    );
  }
}
