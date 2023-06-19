import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class LogViewPage extends StatelessWidget {
  final LogReader reader = LogReader();

  LogViewPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.messageLogViewer),
          elevation: 0.0,
        ),
        body: Padding(
          padding: Dimensions.paddingContents,
          child: LogView(reader, theme: LogViewTheme.system(context)),
        ),
      );
}
