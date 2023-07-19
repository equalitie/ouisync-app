import 'package:flutter/material.dart';

import '../utils/utils.dart';

class EqTermsAndPrivacy extends StatelessWidget {
  const EqTermsAndPrivacy({super.key});

  @override
  Widget build(BuildContext context) => Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
          childrenPadding: EdgeInsets.symmetric(vertical: 20.0),
          title: Text('Tap here to read our Terms of Use and Privacy Notice',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSmall,
                  fontStyle: FontStyle.italic)),
          children: [_temsAndPrivacyTextBlock(context)]));

  Widget _temsAndPrivacyTextBlock(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                style: TextStyle(
                    color: Colors.black87, fontSize: Dimensions.fontSmall),
                children: [
                  Fields.boldTextSpan(
                      '\nOuisync Terms of Use & Privacy Notice\n',
                      fontSize: Dimensions.fontBig)
                ])),
        RichText(
          text: TextSpan(
            style: TextStyle(
                color: Colors.black87, fontSize: Dimensions.fontSmall),
            children: [
              Fields.boldTextSpan('1. Overview\n\n'),
              TextSpan(
                  text:
                      'This Ouisync Terms of Use (the “Agreement”), along with'
                      ' our Privacy Notice (collectively, the “Terms”), govern your '
                      'use of Ouisync - an online file synchronization protocol and software.\n\n'),
              TextSpan(
                  text: 'By installing and running the Ouisync application, you'
                      ' indicate your assent to be bound by and to comply with '
                      'this Agreement between you and eQualitie inc. '
                      '(“eQualitie”, “we”, or “us”). Usage of the Ouisync '
                      'application and the Ouisync network (the Service) is '
                      'provided by eQualitie at no cost and is intended for use'
                      ' as is.\n\n'),
              Fields.boldTextSpan('2. Terms of use\n\n'),
              TextSpan(
                  text: 'The Ouisync application is built in-line with '
                      'eQualitie’s values. By using this software you agree that'
                      ' you will not use Ouisync to publish, share, or store '
                      'materials that is contrary to the underlying values nor '
                      'the letter of the laws of Quebec or Canada or the '
                      'International Bill of Human Rights, including content '
                      'that:\n\n'),
              TextSpan(
                  text: '·	Infringes on personal information protection rights,'
                      ' including the underlying values or the letter of '),
              Fields.linkTextSpan(context, 'Canada’s Privacy Act', _launchCPA),
              TextSpan(text: ' or '),
              Fields.linkTextSpan(context, 'PIPEDA', _launchPIPEDA),
              TextSpan(
                  text: ' (the Personal Information Protection and Electronic '
                      'Documents Act),\n\n'),
              Fields.boldTextSpan('·	'),
              TextSpan(
                  text: 'Constitutes child sexually exploitative material '
                      '(including material which may not be illegal child sexual'
                      ' abuse material but which nonetheless sexually exploits '
                      'or promotes the sexual exploitation of minors), unlawful '
                      'pornography, or are otherwise indecent;\n\n'),
              Fields.boldTextSpan('·	'),
              TextSpan(
                  text: 'Contains or promotes extreme acts of violence or '
                      'terrorist activity, including terror or violent extremist'
                      ' propaganda;\n\n'),
              Fields.boldTextSpan('·	'),
              TextSpan(
                  text: 'Advocates bigotry, hatred, or the incitement of '
                      'violence against any person or group of people based on '
                      'their race, religion, ethnicity, national origin, sex, '
                      'gender identity, sexual orientation, disability, '
                      'impairment, or any other characteristic(s) associated '
                      'with systemic discrimination or marginalization;\n\n'),
              Fields.boldTextSpan('·	'),
              TextSpan(
                  text: 'Files that contain viruses, trojans, worms, logic '
                      'bombs or other material that is malicious or '
                      'technologically harmful.\n\n'),
              Fields.boldTextSpan('3. Privacy Notice\n\n'),
              TextSpan(
                  text: 'This section is used to inform visitors regarding our '
                      'policies with the collection, use, and disclosure of '
                      'Personal Information if anyone decides to use our '
                      'Service.\n\n'),
              Fields.boldTextSpan('3.1 Data Collection\n\n',
                  fontSize: Dimensions.fontMicro),
              TextSpan(
                  text:
                      'The OuiSync team values user privacy and thus does not '
                      'collect any user information.\n\n'),
              TextSpan(
                  text:
                      'The Ouisync app is designed to be able to provide file '
                      'sharing services without a user ID, name, nickname, user '
                      'account or any other form of user data. We don\'t know '
                      'who uses our app and with whom they sync or share their '
                      'data.\n\n'),
              Fields.boldTextSpan('3.2 Data Sharing\n\n',
                  fontSize: Dimensions.fontMicro),
              TextSpan(
                  text: 'Ouisync (and eQualit.ie) does not share any data with '
                      'any third parties.\n\n'),
              Fields.boldTextSpan('3.3 Security Practices\n\n',
                  fontSize: Dimensions.fontMicro),
              TextSpan(
                  text: 'Data that the user uploads into the Ouisync '
                      'repositories is end-to-end encrypted in transit as well '
                      'as at rest. This includes metadata such as file names, '
                      'sizes, folder structure etc. Within Ouisync, data is '
                      'readable only by the person who uploaded the data and '
                      'those persons with whom they shared their '
                      'repositories.\n\n'),
              TextSpan(
                  text:
                      'You can learn more about the encryption techniques used '
                      'in our documentation.\n\n'),
              TextSpan(
                  text: 'The Ouisync app stores users\' data on an \'Always-On '
                      'Peer\', which is a server located in Canada. All data is'
                      ' stored as encrypted chunks and is not readable by the '
                      'server or its operators. The purpose of this server is '
                      'simply to bridge the gaps between peers who are not '
                      'online at the same time. All data is periodically purged'
                      ' from this server - its purpose is not to provide '
                      'permanent data storage but simply facilitation of data '
                      'syncing by peers.\n\n'),
              TextSpan(
                  text:
                      'If you have a reason to believe that your personal data'
                      ' has been illegaly obtained and shared by other Ouisync '
                      'users, please contact us at the address below.\n\n'),
              Fields.boldTextSpan(
                  '3.4 Deletion of your data from our Always-On-Peer server\n\n',
                  fontSize: Dimensions.fontMicro),
              TextSpan(
                  text: 'The simplest way to delete your data is by deleting '
                      'files or repositories from your own device. Any file '
                      'deletion will be propagated to all your peers - ie, if '
                      'you have Write access to a repository, you can delete any'
                      ' files within it and the same files will be deleted from'
                      ' your peers\' repositories as well as from our '
                      'Always-On-Peer. If you need to delete only the '
                      'repositories from our Always-On-Peer (but still keep them'
                      ' in your own repository on your own device), please '
                      'contact us at the address below.\n\n'),
              Fields.italicTextSpan('Note: ',
                  fontSize: Dimensions.fontMicro, fontWeight: FontWeight.bold),
              Fields.italicTextSpan(
                  'The Ouisync team cannot delete '
                  'individual files from repositories, as it is not possible to'
                  ' identify them because they are encrypted. We are able to '
                  'delete whole repositories if you send us the link to the '
                  'repository that needs to be deleted.\n\n',
                  fontSize: Dimensions.fontMicro),
              Fields.boldTextSpan('Log Data\n\n'),
              TextSpan(
                  text: 'The OuiSync app creates logfiles on users\' devices. '
                      'Their purpose is only to log device\'s activity to '
                      'facilitate the debugging process in case the user '
                      'experiences difficulties in connecting with their peers '
                      'or otherwise in using the Ouisync app. The logfile '
                      'remains on a user\'s device unless the user decides to '
                      'send it to us for support purposes\n\n'),
              TextSpan(
                  text: 'If the user does decide to contact us, the personally '
                      'indetifiable data we may collect is:\n\n'),
              Fields.boldTextSpan('·	'),
              TextSpan(
                  text: 'Email address - if the user decided to contact us by '
                      'email;\n\n'),
              Fields.boldTextSpan('·	'),
              TextSpan(
                  text: 'Information the user may provide by email, through '
                      'help tickets, or through our website, and associated '
                      'metadata - for the purposes of providing technical '
                      'support;\n\n'),
              Fields.boldTextSpan('·	'),
              TextSpan(
                  text: 'User’s IP address - for the purposes of providing '
                      'technical support.\n\n'),
              TextSpan(
                  text:
                      'None of this data is shared with any third parties.\n\n'),
              Fields.boldTextSpan('Cookies\n\n'),
              TextSpan(text: 'The Ouisync app does not use cookies.\n\n'),
              Fields.boldTextSpan('Links to Other Sites\n\n'),
              TextSpan(
                  text: 'This Service may contain links to other sites. If you '
                      'click on a third-party link, you will be directed to that'
                      ' site. Note that these external sites are not operated by'
                      ' us. Therefore, we strongly advise you to review the '
                      'Privacy Policy of these websites. We have no control over'
                      ' and assume no responsibility for the content, privacy '
                      'policies, or practices of any third-party sites or '
                      'services.\n\n'),
              Fields.boldTextSpan('Children’s Privacy\n\n'),
              TextSpan(
                  text: 'We do not knowingly collect personally identifiable '
                      'information from children. We encourage all children to '
                      'never submit any personally identifiable information '
                      'through the Application and/or Services. We encourage '
                      'parents and legal guardians to monitor their childrens\''
                      ' Internet usage and to help enforce this Policy by '
                      'instructing their children never to provide personally '
                      'identifiable information through the Application and/or '
                      'Services without their permission. If you have reason to '
                      'believe that a child has provided personally identifiable'
                      ' information to us through the Application and/or '
                      'Services, please contact us. You must also be at least '
                      '16 years of age to consent to the processing of your '
                      'personally identifiable information in your country (in '
                      'some countries we may allow your parent or guardian to do'
                      ' so on your behalf).\n\n'),
              Fields.boldTextSpan('Changes to these Terms\n\n'),
              TextSpan(
                  text:
                      'We may update our Terms from time to time. Thus, you are '
                      'advised to review this page periodically for any changes.'
                      '\n\nThis policy is effective as of 2022-03-09\n\n'),
              Fields.boldTextSpan('Contact Us\n\n'),
              TextSpan(
                  text: 'If you have any questions or suggestions about our '
                      'Privacy Policy, do not hesitate to contact us at '),
              Fields.linkTextSpan(context, 'support@ouisync.net', (context) {}),
              TextSpan(text: '.'),
            ],
          ),
        )
      ]);

  void _launchCPA(BuildContext context) async {
    final title = Text('Canada’s Privacy Act');
    await Fields.openUrl(context, title, Constants.canadaPrivacyAct);
  }

  void _launchPIPEDA(BuildContext context) async {
    final title =
        Text('The Personal Information Protection and Electronic Documents Act '
            '(PIPEDA)');
    await Fields.openUrl(context, title, Constants.pipedaUrl);
  }
}
