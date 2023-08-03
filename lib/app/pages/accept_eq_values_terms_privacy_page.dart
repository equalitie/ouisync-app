import 'dart:io';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class AcceptEqualitieValuesTermsPrivacyPage extends StatefulWidget {
  const AcceptEqualitieValuesTermsPrivacyPage(
      {required this.settings, required this.ouisyncAppHome});

  final Settings settings;
  final Widget ouisyncAppHome;

  @override
  State<AcceptEqualitieValuesTermsPrivacyPage> createState() =>
      _AcceptEqualitieValuesTermsPrivacyPageState();
}

class _AcceptEqualitieValuesTermsPrivacyPageState
    extends State<AcceptEqualitieValuesTermsPrivacyPage> {
  TextStyle? introTextStyle;
  TextStyle? bodyTextStyle;
  TextStyle? byTextStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    introTextStyle = Theme.of(context).textTheme.titleMedium;
    bodyTextStyle = Theme.of(context).textTheme.bodyMedium;
    byTextStyle = TextStyle(
        fontSize: (bodyTextStyle?.fontSize ?? 10.0) * 0.8,
        color: Colors.black54);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: PlatformValues.isMobileDevice
          ? AppBar(title: Text(S.current.titleAppTitle))
          : null,
      body: SingleChildScrollView(
          child: Center(
              child: Container(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _headerImages(),
                        const SizedBox(height: 60.0),
                        _introTextSpan(),
                        const SizedBox(height: 20.0),
                        EqValues(),
                        EqTermsAndPrivacy(),
                        const SizedBox(height: 20.0),
                        Fields.dialogActions(context,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            buttons: _actions())
                      ])))));

  Widget _headerImages() => Column(children: [
        Image.asset(Constants.ouisyncLogoFull,
            width: MediaQuery.of(context).size.width * 0.6),
        Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(S.current.messageBy, style: byTextStyle)),
        Image.asset(Constants.eQLogo,
            width: MediaQuery.of(context).size.width * 0.2)
      ]);

  Widget _introTextSpan() => RichText(
      textAlign: TextAlign.start,
      text: TextSpan(style: bodyTextStyle, children: [
        Fields.boldTextSpan(S.current.titleAppTitle),
        TextSpan(text: ' ${S.current.messageEqualitieValues}')
      ]));

  List<Widget> _actions() => [
        OutlinedButton(
            onPressed: () => exit(0),
            child: Text(S.current.actionIDontAgree.toUpperCase())),
        ElevatedButton(
            onPressed: () async {
              await widget.settings.setEqualitieValues(true);

              await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => widget.ouisyncAppHome));
            },
            autofocus: true,
            child: Text(S.current.actionIAgree.toUpperCase()))
      ];
}
