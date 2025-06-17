import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart' show Dimensions, LogReader;
import '../widgets/widgets.dart' show DirectionalAppBar, LogView, LogViewTheme;

class LogViewPage extends StatelessWidget {
  final LogReader reader = LogReader();

  LogViewPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DirectionalAppBar(title: Text(S.current.messageLogViewer)),
    body: Padding(
      padding: Dimensions.paddingContents,
      child: LogView(reader, theme: LogViewTheme.system(context)),
    ),
  );
}
