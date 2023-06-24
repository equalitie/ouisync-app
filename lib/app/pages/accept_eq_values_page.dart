import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/platform/platform.dart';

import '../../generated/l10n.dart';
import '../app.dart';
import '../utils/utils.dart';
import 'pages.dart';

class AcceptEqualitieValuesPage extends StatelessWidget {
  const AcceptEqualitieValuesPage(
      {required this.settings, required this.ouisyncAppHome});

  final Settings settings;
  final OuiSyncApp ouisyncAppHome;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: PlatformValues.isMobileDevice
          ? AppBar(title: Text(S.current.titleAppTitle))
          : null,
      body: Center(
          child: Container(
              padding: Dimensions.paddingAll20,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Constants.eQLogo,
                        width: MediaQuery.of(context).size.width * 0.4),
                    const SizedBox(height: 60.0),
                    Text(S.current.messageEqualitieValues),
                    const SizedBox(height: 40.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () async {
                              final webView = PlatformWebView();

                              if (PlatformValues.isDesktopDevice) {
                                await webView.launchUrl(Constants.eqValuesUrl);
                                return;
                              }

                              final title = Text(S.current.titleOurValues);
                              final content =
                                  await Dialogs.executeFutureWithLoadingDialog(
                                      context,
                                      f: webView.loadUrl(
                                          context, Constants.eqValuesUrl));

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebViewPage(
                                          title: title, content: content)));
                            },
                            child: Text(S.current.titleOurValues,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                )),
                          )
                        ]),
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
