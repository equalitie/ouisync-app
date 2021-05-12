import 'package:flutter/material.dart';
import 'package:ouisync_app/app/pages/pages.dart';

class ReceiveSharingIntentPage extends StatefulWidget {
  static const String routeName = '/receiveSharingIntent';

  @override
  _ReceiveSharingIntentPageState createState() => _ReceiveSharingIntentPageState();
}

class _ReceiveSharingIntentPageState extends State<ReceiveSharingIntentPage> {
  final _receiveSharingIntentBloc = ReceiveSharingIntentBloc(UnReceiveSharingIntentState());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ReceiveSharingIntent'),
      ),
      body: ReceiveSharingIntentScreen(receiveSharingIntentBloc: _receiveSharingIntentBloc),
    );
  }
}
