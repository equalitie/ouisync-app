import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ouisync_app/app/widgets/eq_terms_privacy.dart';
import '../widgets/eq_values.dart';

import '../../generated/l10n.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';

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
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: PlatformValues.isMobileDevice
          ? AppBar(title: Text(S.current.titleAppTitle))
          : null,
      body: SingleChildScrollView(
          child: Center(
              child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _headerImages(),
                        const SizedBox(height: 60.0),
                        _introTextSpan(),
                        const SizedBox(height: 20.0),
                        EqValues(),
                        const SizedBox(height: 20.0),
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
            child: Text(S.current.messageBy,
                style: TextStyle(color: Colors.black54, fontSize: 8.0))),
        Image.asset(Constants.eQLogo,
            width: MediaQuery.of(context).size.width * 0.2)
      ]);

  Widget _introTextSpan() => RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
          style:
              TextStyle(color: Colors.black87, fontSize: Dimensions.fontSmall),
          children: [
            Fields.boldTextSpan(S.current.titleAppTitle),
            TextSpan(text: ' ${S.current.messageEqualitieValues}')
          ]));

  List<Widget> _actions() => [
        TextButton(
            onPressed: () => exit(0), child: Text(S.current.actionIDontAgree)),
        TextButton(
            onPressed: () async {
              await widget.settings.setEqualitieValues(true);

              await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => widget.ouisyncAppHome));
            },
            child: Text(S.current.actionIAgree))
      ];
}
