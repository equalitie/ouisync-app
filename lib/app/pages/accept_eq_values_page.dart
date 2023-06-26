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

  Image _headerImages() {
    return Image.asset(Constants.eQLogo,
        width: MediaQuery.of(context).size.width * 0.4);
  }

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
    return ExpansionTile(
        childrenPadding: EdgeInsets.symmetric(vertical: 20.0),
        title: Text('Tap here to read our values',
            textAlign: TextAlign.end,
            style: TextStyle(
                fontSize: Dimensions.fontSmall, fontStyle: FontStyle.italic)),
        children: [_valuesTextBlock()]);
  }

  Widget _valuesTextBlock() =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                style: TextStyle(
                    color: Colors.black87, fontSize: Dimensions.fontSmall),
                children: [
                  _boldTextSpan('\neQualitie’s Values\n',
                      fontSize: Dimensions.fontBig)
                ])),
        RichText(
            textAlign: TextAlign.end,
            text: _quoteTextSpan(
                '“Man is born free, and everywhere he is in chains.”',
                'Jean-Jacques Rousseau')),
        RichText(
          text: TextSpan(
            style: TextStyle(
                color: Colors.black87, fontSize: Dimensions.fontSmall),
            children: [
              TextSpan(
                  text: 'Basic rights and fundamental freedoms are inherent'
                      ', inalienable and apply equally to everyone. Human rights '
                      'are universal; protected in international law and enshrined'
                      ' in the '),
              _linkTextSpan(
                  'International Bill of Human Rights.', _launchIBoHR),
              TextSpan(
                  text: 'Brave people risk life and liberty to defend human'
                      ' rights, to mobilise, to criticise and to expose the '
                      'perpetrators of abuse. Brave people voice support for '
                      'others, for ideas, and communicate their concerns to the'
                      ' world. These brave people exercise their human rights'
                      ' online.\n\n'),
              TextSpan(
                  text: 'The Internet is a platform for free expression and '
                      'self-determination. Like any communication tool, the '
                      'Internet is not immune from censorship, surveillance, '
                      'attacks and attempts by state actors and criminal groups'
                      ' to silence dissident voices. When democratic expression'
                      ' is criminalised, when there is ethnic and political'
                      ' discrimination, the Internet becomes another '
                      'battleground for non-violent resistance.\n\n'),
              _boldTextSpan('Our mission\n\n'),
              TextSpan(
                  text: 'Our mission is to promote and defend fundamental'
                      ' freedoms and human rights, including the free flow of '
                      'information online. Our goal is to create accessible '
                      'technology and improve the skill set needed for '
                      'defending human rights and freedoms in the digital age.\n\n'),
              TextSpan(
                  text: 'We aim to educate and raise the capacity of our'
                      ' constituents to enjoy secure operations in the digital'
                      ' domain. We do this by building tools that enable and'
                      ' protect free expression, circumvent censorship, empower'
                      ' anonymity and protect from surveillance where and when'
                      ' necessary. Our tools also improve information management'
                      ' and analytic functions.\n\n'),
              _boldTextSpan('We are eQualit.ie\n\n'),
              TextSpan(
                  text: 'We are an international group of activists of diverse'
                      ' backgrounds and beliefs, standing together to defend the'
                      ' principles common among us. We are software developers,'
                      ' cryptographers, security specialists, as well as '
                      'educators, sociologists, historians, anthropologists and'
                      ' journalists. We develop open and reusable tools with a'
                      ' focus on privacy, online security and better information'
                      ' management. We finance our operations with public grants'
                      ' and consultancies with the private sector. We believe'
                      ' in an Internet that is free from intrusive and '
                      'unjustified surveillance, censorship and oppression.\n\n'),
              _boldTextSpan('Our Principles\n\n'),
              TextSpan(
                  text:
                      'Inspired by the International Bill of Human Rights, our'
                      ' principles apply to every individual, group and organ of'
                      ' society that we work with, including the beneficiaries'
                      ' of the software and services we release. All of our'
                      ' projects are designed with our principles in mind. Our'
                      ' knowledge, tools and services are available to these'
                      ' groups and individuals as long as our principles and'
                      ' terms of service are respected.\n\n'),
              _boldTextSpan('- Privacy\n\n'),
              TextSpan(
                  text: 'The right to privacy is a fundamental right that we'
                      ' aim to protect whenever and wherever possible. The'
                      ' privacy of our direct beneficiaries is sacrosanct to'
                      ' our operations. Our tools, services and internal'
                      ' policies are designed to this effect. We will use all'
                      ' technical and legal resources at our disposal to protect'
                      ' the privacy of our beneficiaries. Please refer to our'
                      ' Privacy Policy and our '),
              _linkTextSpan(
                  'Declaration for Distributed Online Services.', _launchDfDOS),
              _boldTextSpan('- Digital Security\n\n'),
              TextSpan(
                  text: 'Security is a constant thematic throughout all of our'
                      ' software development, service provision and'
                      ' capacity-building projects. We design our systems and'
                      ' processes to improve information security on the'
                      ' Internet and raise the user’s security profile and'
                      ' experience. We try to lead by example by not'
                      ' compromising the security properties of a tool or'
                      ' system for the sake of speed, usability or cost. We do'
                      ' not believe in security through obscurity and we'
                      ' maintain transparency through open access to our code'
                      ' base. We always err on the side of caution and try to'
                      ' implement good internal operational security.\n\n'),
              _boldTextSpan('- Openness and Transparency\n\n'),
              TextSpan(
                  text: 'As an organisation, we seek to be transparent with our'
                      ' policies and procedures. As often as possible, our'
                      ' source code is open and freely available, protected by'
                      ' licences that encourage community-driven development,'
                      ' sharing and the propagation of these principles.\n\n'),
              _boldTextSpan(
                  '- Freedom of expression and access to information\n\n'),
              TextSpan(
                  text: 'The ability to express oneself freely and to access'
                      ' public information is the backbone of a true democracy.'
                      ' Public information should be in the public domain.'
                      ' Freedom of expression includes active and heated debate,'
                      ' even arguments that are inelegantly articulated, poorly'
                      ' constructed and that may be considered offensive to'
                      ' some. However, freedom of expression is not an absolute'
                      ' right. We stand firmly against violence and the'
                      ' incitement to violate the rights of others, especially'
                      ' the propagation of violence, hate, discrimination and'
                      ' disenfranchisement of any identifiable ethnic or social'
                      ' group.\n\n'),
              _boldTextSpan('- Just and legal society\n\n'),
              TextSpan(
                  text: 'We operate from different countries and come from'
                      ' various social backgrounds. We work together towards a'
                      ' society that will respect and defend the rights of others'
                      ' in the physical and the digital world. The International'
                      ' Bill of Rights articulates the suite of human rights that'
                      ' inspires our work; we believe that people have a right and'
                      ' a duty to protect these rights.\n\n'
                      'We understand that our tools and services can be abused'
                      ' to contravene these principles and our terms of service,'
                      ' and we firmly and actively condemn and forbid such'
                      ' usage. We neither permit our software and services to be'
                      ' used to further the commission of illicit activities,'
                      ' nor will we assist in the propagation of hate speech or'
                      ' the promotion of violence through the Internet.\n\n'
                      'We have put safeguards in place to mitigate the misuse'
                      ' of our products and services. When we become aware of'
                      ' any use that violates our principles or terms of'
                      ' service, we take action to stop it. Guided by our'
                      ' internal policies, we carefully deliberate over acts'
                      ' that might compromise our principles. Our procedures'
                      ' will continue to evolve based on experience and best'
                      ' practices so that we can achieve the right balance'
                      ' between enabling open access to our products and'
                      ' services, and upholding our principles.'),
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
    final title = Text('International Bill of Human Rights');
    await _openUrl(title, Constants.billHumanRightsUrl);
  }

  void _launchDfDOS() async {
    final title = Text('Declaration for Distributed Online Services');
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
