import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import 'pages.dart';

class AcceptEqualitieValuesPage extends StatefulWidget {
  const AcceptEqualitieValuesPage(
      {required this.settings, required this.ouisyncAppHome});

  final Settings settings;
  final Widget ouisyncAppHome;

  @override
  State<AcceptEqualitieValuesPage> createState() =>
      _AcceptEqualitieValuesPageState();
}

class _AcceptEqualitieValuesPageState extends State<AcceptEqualitieValuesPage> {
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
                        _valuesExpansionPanel(),
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
            _boldTextSpan(S.current.titleAppTitle),
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

  Widget _valuesExpansionPanel() {
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
            childrenPadding: EdgeInsets.symmetric(vertical: 20.0),
            title: Text(S.current.messageTapForValues,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSmall,
                    fontStyle: FontStyle.italic)),
            children: [_valuesTextBlock()]));
  }

  Widget _valuesTextBlock() =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                style: TextStyle(
                    color: Colors.black87, fontSize: Dimensions.fontSmall),
                children: [
                  _boldTextSpan('\n${S.current.titleEqualitiesValues}\n',
                      fontSize: Dimensions.fontBig)
                ])),
        RichText(
            textAlign: TextAlign.end,
            text: _quoteTextSpan(
                S.current.messageQuoteMainIsFree, S.current.messageRousseau)),
        RichText(
          text: TextSpan(
            style: TextStyle(
                color: Colors.black87, fontSize: Dimensions.fontSmall),
            children: [
              TextSpan(text: S.current.messageEqValuesP1),
              _linkTextSpan('${S.current.messageInternationalBillHumanRights}.',
                  _launchIBoHR),
              TextSpan(text: '${S.current.messageEqValuesP2}.\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP3}.\n\n'),
              _boldTextSpan('${S.current.titleOurMission}\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP4}.\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP5}.\n\n'),
              _boldTextSpan('${S.current.titleWeAreEq}\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP6}.\n\n'),
              _boldTextSpan('${S.current.titleOurPrinciples}\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP7}.\n\n'),
              _boldTextSpan('- ${S.current.titlePrivacy}\n\n'),
              TextSpan(text: S.current.messageEqValuesP8),
              _linkTextSpan(
                  '${S.current.messageDeclarationDOS}.', _launchDfDOS),
              _boldTextSpan('- ${S.current.titleDigitalSecurity}\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP9}.\n\n'),
              _boldTextSpan('- ${S.current.titleOpennessTransparency}\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP10}\n\n'),
              _boldTextSpan(
                  '- ${S.current.titleFreedomExpresionAccessInfo}\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP11}.\n\n'),
              _boldTextSpan('- ${S.current.titleJustLegalSociety}\n\n'),
              TextSpan(
                  text: '${S.current.messageEqValuesP12}.\n\n'
                      '${S.current.messageEqValuesP13}.\n\n'
                      '${S.current.messageEqValuesP14}.'),
            ],
          ),
        )
      ]);

  TextSpan _boldTextSpan(String text,
          {double fontSize = Dimensions.fontSmall}) =>
      TextSpan(
          text: text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize));

  TextSpan _linkTextSpan(String text, void Function() callback,
          {double fontSize = Dimensions.fontSmall}) =>
      TextSpan(
          text: '$text\n\n',
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blueAccent,
              fontSize: fontSize),
          recognizer: TapGestureRecognizer()..onTap = callback);

  WidgetSpan _quoteTextSpan(String quote, String author,
          {double fontSize = Dimensions.fontSmall}) =>
      WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Text.rich(TextSpan(children: [
            _italicTextSpan(quote, fontSize: fontSize),
            TextSpan(text: '$author\n\n', style: TextStyle(fontSize: fontSize))
          ])));

  TextSpan _italicTextSpan(String text,
          {double fontSize = Dimensions.fontSmall}) =>
      TextSpan(
          text: '$text\n',
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: fontSize));

  void _launchIBoHR() async {
    final title = Text(S.current.messageInternationalBillHumanRights);
    await _openUrl(title, Constants.billHumanRightsUrl);
  }

  void _launchDfDOS() async {
    final title = Text(S.current.messageDeclarationDOS);
    await _openUrl(title, Constants.eqDeclarationDOS);
  }

  Future<void> _openUrl(Widget title, String url) async {
    final webView = PlatformWebView();

    if (PlatformValues.isDesktopDevice) {
      await webView.launchUrl(url);
      return;
    }

    final content = await Dialogs.executeFutureWithLoadingDialog(context,
        f: webView.loadUrl(context, url));

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewPage(title: title, content: content)));
  }
}
