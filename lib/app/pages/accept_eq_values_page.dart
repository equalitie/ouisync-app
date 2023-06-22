import 'dart:io';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../app.dart';
import '../utils/utils.dart';

class AcceptEqualitieValuesPage extends StatelessWidget {
  const AcceptEqualitieValuesPage(
      {required this.settings, required this.ouisyncAppHome});

  final Settings settings;
  final OuiSyncApp ouisyncAppHome;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(
          child: Container(
              padding: Dimensions.paddingAll20,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/eq_logo.png',
                        width: MediaQuery.of(context).size.width - 150),
                    const SizedBox(height: 60.0),
                    Text(S.current.messageEqualitieValues),
                    const SizedBox(height: 20.0),
                    Fields.dialogActions(context,
                        mainAxisAlignment: MainAxisAlignment.end,
                        buttons: _actions(context))
                  ]))));

  List<Widget> _actions(context) => [
        TextButton(
            onPressed: () => exit(0),
            child: Text(S.current.actionNo.toUpperCase())),
        TextButton(
            onPressed: () async {
              await settings.setEqualitieValues(true);

              await Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ouisyncAppHome));
            },
            child: Text(S.current.actionYes.toUpperCase()))
      ];
}
