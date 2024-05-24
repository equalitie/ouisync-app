import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../../cubits/repo.dart';
import '../../utils/utils.dart';

class RepoDescription extends StatelessWidget with AppLogger {
  RepoDescription(
    this.state, {
    required this.isDefault,
  });

  final RepoState state;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    final fontWeight = isDefault ? FontWeight.bold : FontWeight.normal;
    final nameTextStyle = TextStyle(
      fontSize: Theme.of(context).appTextStyle.bodyLarge.fontSize,
      fontWeight: fontWeight,
    );
    final descriptionTextStyle = TextStyle(
      fontSize: Theme.of(context).appTextStyle.bodyMicro.fontSize,
      fontWeight: fontWeight,
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.ellipsedText(
            state.location.name,
            style: nameTextStyle,
            ellipsisPosition: TextOverflowPosition.middle,
          ),
          Fields.autosizeText(
            state.accessMode.name,
            style: descriptionTextStyle,
          ),
        ],
      ),
    );
  }
}
