import 'package:flutter/material.dart';

import '../utils/utils.dart';
import '../widgets/widgets.dart';

class LogViewPage extends StatefulWidget {
  const LogViewPage();

  @override
  State<LogViewPage> createState() => _LogViewPageState();
}

class _LogViewPageState extends State<LogViewPage> {
  late Future<LogReader> _readerFuture;

  @override
  void initState() {
    super.initState();
    _readerFuture = LogReader.open();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Log viewer'),
          elevation: 0.0,
        ),
        body: Padding(
          padding: Dimensions.paddingContents,
          child: FutureBuilder(
            future: _readerFuture,
            builder: (context, snapshot) {
              final reader = snapshot.data;
              if (reader != null) {
                return LogView(reader);
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
      );
}
