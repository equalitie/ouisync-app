import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class RepoDescription extends StatelessWidget with AppLogger {
  RepoDescription({required this.repoData});

  final RepoItem repoData;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontWeight: repoData.isDefault ? FontWeight.bold : FontWeight.normal);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.autosizeText(repoData.name, style: textStyle),
          Fields.autosizeText(repoData.accessMode.name, style: textStyle)
        ],
      ),
    );
  }
}
