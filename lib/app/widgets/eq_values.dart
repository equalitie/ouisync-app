import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/stage.dart';
import '../utils/utils.dart';

class EqValues extends StatelessWidget {
  const EqValues(this.stage, {super.key});

  final Stage stage;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      childrenPadding: EdgeInsetsDirectional.only(bottom: 10.0),
      title: Text(
        S.current.messageTapForValues,
        textAlign: TextAlign.end,
        style: context.theme.appTextStyle.titleSmall.copyWith(
          color: context.theme.primaryColor,
          fontStyle: FontStyle.italic,
        ),
      ),
      children: [_valuesTextBlock(context)],
    ),
  );

  Widget _valuesTextBlock(BuildContext context) {
    final titleFontSize = context.theme.appTextStyle.titleLarge.fontSize;
    final subtitleFontSize = context.theme.appTextStyle.titleMedium.fontSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            style: context.theme.appTextStyle.titleLarge,
            children: [
              Fields.boldTextSpan('\n${S.current.titleEqualitiesValues}\n'),
            ],
          ),
        ),
        RichText(
          textAlign: TextAlign.end,
          text: Fields.quoteTextSpan(
            '${S.current.messageQuoteMainIsFree}\n\n',
            '${S.current.messageRousseau}\n\n',
            fontSize: context.theme.appTextStyle.bodyLarge.fontSize,
          ),
        ),
        RichText(
          text: TextSpan(
            style: context.theme.appTextStyle.bodyMedium,
            children: [
              TextSpan(text: S.current.messageEqValuesP1),
              Fields.linkTextSpan(
                '${S.current.messageInternationalBillHumanRights}.\n\n',
                _launchIBoHR,
              ),
              TextSpan(text: '${S.current.messageEqValuesP2}.\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP3}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleOurMission}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageEqValuesP4}.\n\n'),
              TextSpan(text: '${S.current.messageEqValuesP5}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleWeAreEq}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageEqValuesP6}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleOurPrinciples}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageEqValuesP7}.\n\n'),
              Fields.boldTextSpan(
                '· ${S.current.titlePrivacy}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: S.current.messageEqValuesP8),
              Fields.linkTextSpan(
                '${S.current.messageDeclarationDOS}.\n\n',
                _launchDfDOS,
              ),
              Fields.boldTextSpan(
                '· ${S.current.titleDigitalSecurity}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: '${S.current.messageEqValuesP9}.\n\n'),
              Fields.boldTextSpan(
                '· ${S.current.titleOpennessTransparency}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: '${S.current.messageEqValuesP10}\n\n'),
              Fields.boldTextSpan(
                '· ${S.current.titleFreedomExpressionAccessInfo}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: '${S.current.messageEqValuesP11}.\n\n'),
              Fields.boldTextSpan(
                '· ${S.current.titleJustLegalSociety}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(
                text:
                    '${S.current.messageEqValuesP12}.\n\n'
                    '${S.current.messageEqValuesP13}.\n\n'
                    '${S.current.messageEqValuesP14}.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _launchIBoHR() async {
    final title = Text(S.current.messageInternationalBillHumanRights);
    await Fields.openUrl(stage, title, Constants.billHumanRightsUrl);
  }

  void _launchDfDOS() async {
    final title = Text(S.current.messageDeclarationDOS);
    await Fields.openUrl(stage, title, Constants.eqDeclarationDOS);
  }
}
