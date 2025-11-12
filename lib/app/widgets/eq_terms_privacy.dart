import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../utils/stage.dart';
import '../utils/utils.dart';

class EqTermsAndPrivacy extends StatelessWidget {
  const EqTermsAndPrivacy(this.stage, {super.key});

  final Stage stage;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final headerTextStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: primaryColor,
      fontStyle: FontStyle.italic,
    );

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        childrenPadding: EdgeInsetsDirectional.symmetric(vertical: 20.0),
        title: Text(
          S.current.messageTapForTermsPrivacy,
          textAlign: TextAlign.end,
          style: headerTextStyle,
        ),
        children: [_temsAndPrivacyTextBlock(context)],
      ),
    );
  }

  Widget _temsAndPrivacyTextBlock(BuildContext context) {
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
              Fields.boldTextSpan('\n${S.current.titleTermsPrivacy}\n'),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: context.theme.appTextStyle.bodyMedium,
            children: [
              Fields.boldTextSpan(
                '${S.current.titleOverview}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageTermsPrivacyP1}.\n\n'),
              TextSpan(text: '${S.current.messageTermsPrivacyP2}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleTermsOfUse}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageTermsPrivacyP3}\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: S.current.messageTerms1_1),
              Fields.linkTextSpan(
                S.current.messageCanadaPrivacyAct,
                _launchCPA,
              ),
              TextSpan(text: ' ${S.current.messageOr.toLowerCase()} '),
              Fields.linkTextSpan(S.current.messagePIPEDA, _launchPIPEDA),
              TextSpan(text: ' ${S.current.messageTerms1_2},\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: '${S.current.messageTerms2};\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: '${S.current.messageTerms3};\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: '${S.current.messageTerms4};\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: '${S.current.messageTerms5}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titlePrivacyNotice}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messagePrivacyIntro}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleDataCollection}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: '${S.current.messageDataCollectionP1}.\n\n'),
              TextSpan(text: '${S.current.messageDataCollectionP2}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleDataSharing}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: '${S.current.messageDataSharingP1}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleSecurityPractices}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: '${S.current.messageSecurityPracticesP1}.\n\n'),
              TextSpan(text: '${S.current.messageSecurityPracticesP2}.\n\n'),
              TextSpan(text: '${S.current.messageSecurityPracticesP3}.\n\n'),
              TextSpan(text: '${S.current.messageSecurityPracticesP4}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleDeletionDataServer}\n\n',
                fontSize: subtitleFontSize,
              ),
              TextSpan(text: '${S.current.messageDeletionDataServerP1}.\n\n'),
              Fields.italicTextSpan('${S.current.messageNote}: '),
              Fields.italicTextSpan(
                '${S.current.messageDeletionDataServerNote}.\n\n',
              ),
              Fields.boldTextSpan(
                '${S.current.titleLogData}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageLogDataP1}.\n\n'),
              TextSpan(text: '${S.current.messageLogDataP2}\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: '${S.current.messageLogData1};\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: '${S.current.messageLogData2};\n\n'),
              Fields.boldTextSpan('·	', fontSize: subtitleFontSize),
              TextSpan(text: '${S.current.messageLogData3}.\n\n'),
              TextSpan(text: '${S.current.messageLogDataP3}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleCookies}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageCookiesP1}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleLinksOtherSites}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageLinksOtherSitesP1}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleChildrensPrivacy}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageChildrensPolicyP1}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleChangesToTerms}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageChangesToTermsP1}.\n\n'),
              TextSpan(text: '${S.current.messageChangesToTermsP2}.\n\n'),
              Fields.boldTextSpan(
                '${S.current.titleContactUs}\n\n',
                fontSize: titleFontSize,
              ),
              TextSpan(text: '${S.current.messageContatUsP1} '),
              Fields.linkTextSpan(Constants.supportEmail, _mailTo),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }

  void _mailTo() => launchUrl(Uri.parse('mailto:${Constants.supportEmail}'));

  void _launchCPA() async {
    final title = Text(S.current.messageCanadaPrivacyAct);
    await Fields.openUrl(stage, title, Constants.canadaPrivacyAct);
  }

  void _launchPIPEDA() async {
    final title = Text(S.current.titlePIPEDA);
    await Fields.openUrl(stage, title, Constants.pipedaUrl);
  }
}
