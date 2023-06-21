import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import 'app_version_tile.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class AboutSection extends SettingsSection {
  AboutSection({required this.repos}) : super(title: S.current.titleAbout);

  final ReposCubit repos;

  @override
  List<Widget> buildTiles(BuildContext context) => [
        NavigationTile(
            title: Text(S.current.titleFAQShort),
            leading: Icon(Icons.question_answer_rounded),
            value: Text(S.current.messageFAQ),
            onTap: () => unawaited(_openFaq(context))),
        SettingsTile(
          title: Text('Feedback'), // TODO: S.current.labelFeedback
          leading: Icon(Icons.mail),
          onTap: _sendFeedback,
        ),
        AppVersionTile(
          session: repos.session,
          leading: Icon(Icons.info_outline),
          title: Text(S.current.labelAppVersion),
        ),
        SettingsTile(
          title: Text(S.current.messageSettingsRuntimeID),
          leading: Icon(Icons.person),
          value: _getRuntimeIdForOS(),
        ),
      ];

  Future<void> _openFaq(BuildContext context) async {
    final webView = PlatformWebView();

    if (PlatformValues.isMobileDevice) {
      final title = Text(S.current.titleFAQShort);
      final content = await Dialogs.executeFutureWithLoadingDialog(context,
          f: webView.loadUrl(context, Constants.faqUrl));

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(title: title, content: content)));
    } else {
      await webView.launchUrl(Constants.faqUrl);
    }
  }

  Widget _getRuntimeIdForOS() => FutureBuilder(
      future: repos.session.thisRuntimeId,
      builder: (context, snapshot) {
        final runtimeId = snapshot.data ?? '';
        final runtimeIdWidget = Text(
          runtimeId,
          overflow: TextOverflow.ellipsis,
        );

        if (Platform.isIOS) {
          return Expanded(
            child: Row(children: [Expanded(child: runtimeIdWidget)]),
          );
        }

        return runtimeIdWidget;
      });

  Future<void> _sendFeedback() async {}
}
