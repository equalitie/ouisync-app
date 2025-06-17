import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class MissingRepoDescription extends StatelessWidget {
  const MissingRepoDescription(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Fields.autosizeText(name),
        Fields.autosizeText(S.current.messageRepoMissing),
      ],
    ),
  );
}
