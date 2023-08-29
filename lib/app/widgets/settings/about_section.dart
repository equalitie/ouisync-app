import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../pages/peer_list.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../widgets.dart';
import 'app_version_tile.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class AboutSection extends SettingsSection with AppLogger {
  AboutSection(this._cubits) : super(title: S.current.titleAbout) {
    _launchAtStartup = ValueNotifier<bool>(
        _cubits.repositories.settings.getLaunchAtStartup() ?? true);
  }

  final Cubits _cubits;
  late final ValueNotifier<bool> _launchAtStartup;

  TextStyle? bodyStyle;

  @override
  List<Widget> buildTiles(BuildContext context) {
    bodyStyle = context.theme.appTextStyle.bodyMedium;

    return [
      if (PlatformValues.isDesktopDevice)
        ValueListenableBuilder(
            valueListenable: _launchAtStartup,
            builder: (context, value, child) => SwitchSettingsTile(
                value: value,
                onChanged: (value) => unawaited(_updateLaunchAtStartup(value)),
                title: Text(S.current.messageLaunchAtStartup, style: bodyStyle),
                leading: Icon(Icons.rocket_launch_sharp))),
      NavigationTile(
          title: Text(S.current.titleFAQShort, style: bodyStyle),
          leading: Icon(Icons.question_answer_rounded),
          trailing:
              PlatformValues.isDesktopDevice ? _externalNavigationIcon : null,
          value: Text(S.current.messageFAQ,
              style: context.theme.appTextStyle.bodySmall),
          onTap: () => unawaited(
              _openUrl(context, S.current.titleFAQShort, Constants.faqUrl))),
      NavigationTile(
          title: Text(S.current.titlePrivacyPolicy, style: bodyStyle),
          leading: Icon(Icons.privacy_tip_rounded),
          trailing:
              PlatformValues.isDesktopDevice ? _externalNavigationIcon : null,
          onTap: () => unawaited(_openUrl(context, S.current.titlePrivacyPolicy,
              Constants.eqPrivacyPolicy))),
      if (PlatformValues.isMobileDevice)
        NavigationTile(
          title: Text(S.current.titleSendFeedback, style: bodyStyle),
          leading: Icon(Icons.comment_rounded),
          onTap: () => unawaited(_openFeedback(context)),
        ),
      NavigationTile(
        title: Text(Constants.ouisyncUrl, style: bodyStyle),
        // Icons.language is actually a stylized globe icon which is a good fit here:
        leading: Icon(Icons.language_rounded),
        trailing: _externalNavigationIcon,
        onTap: () => unawaited(launchUrl(Uri.parse(Constants.ouisyncUrl))),
      ),
      NavigationTile(
        title: Text(Constants.supportEmail, style: bodyStyle),
        leading: Icon(Icons.mail_rounded),
        trailing: _externalNavigationIcon,
        onTap: () =>
            unawaited(launchUrl(Uri.parse('mailto:${Constants.supportEmail}'))),
      ),
      NavigationTile(
        title: Text(S.current.titleIssueTracker, style: bodyStyle),
        leading: Icon(Icons.bug_report_rounded),
        trailing: _externalNavigationIcon,
        onTap: () => unawaited(launchUrl(Uri.parse(Constants.issueTrackerUrl))),
      ),
      AppVersionTile(
        session: _cubits.repositories.session,
        leading: Icon(Icons.info_rounded),
        title: Text(S.current.labelAppVersion, style: bodyStyle),
      ),
      SettingsTile(
        title: BlocBuilder<PeerSetCubit, PeerSet>(
            builder: (context, state) => InfoBuble(
                    child: Text(S.current.messageSettingsRuntimeID,
                        style: bodyStyle),
                    title: S.current.messageSettingsRuntimeID,
                    description: [
                      TextSpan(text: S.current.messageInfoRuntimeID),
                      Fields.linkTextSpan(
                          context,
                          '\n\n${S.current.messageGoToPeers}',
                          _navigateToPeers),
                    ])),
        leading: Icon(Icons.person_rounded),
        value: _getRuntimeIdForOS(),
      ),
    ];
  }

  void _navigateToPeers(BuildContext context) async {
    final peerSetCubit = context.read<PeerSetCubit>();

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider.value(
                  value: peerSetCubit,
                  child: PeerList(),
                )));
  }

  @override
  bool containsErrorNotification() {
    return _cubits.upgradeExists.state;
  }

  Future<void> _updateLaunchAtStartup(bool value) async {
    await _cubits.windowManager.launchAtStartup(value);
    await _cubits.repositories.settings.setLaunchAtStartup(value);

    _launchAtStartup.value = value;
  }

  Future<void> _openUrl(BuildContext context, String title, String url) async {
    final webView = PlatformWebView();

    if (PlatformValues.isMobileDevice) {
      final pageTitle = Text(title);
      final content = await Dialogs.executeFutureWithLoadingDialog(context,
          f: webView.loadUrl(context, url));

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(title: pageTitle, content: content)));
    } else {
      await webView.launchUrl(url);
    }
  }

  Future<void> _openFeedback(BuildContext context) async {
    final attachments = await showDialog<FeedbackAttachments>(
      context: context,
      builder: (context) => FeedbackDialog(),
    );

    if (attachments == null) {
      return;
    }

    if (attachments.logs) {
      final logs = await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: dumpAll(
          context,
          _cubits.repositories.rootStateMonitor,
          compress: true,
        ),
      );

      try {
        await _sendFeedback(logs);
      } finally {
        await logs.delete();
      }
    } else {
      await _sendFeedback(null);
    }
  }

  Future<void> _sendFeedback(File? logs) async {
    final email = Email(
      recipients: const [Constants.supportEmail],
      attachmentPaths: [if (logs != null) logs.path],
    );

    if (logs != null) {
      final name = basename(logs.path);
      final size = formatSize(await logs.length());

      loggy.debug('Sending feedback email with attachment: $name, $size');
    } else {
      loggy.debug('Sending feedback email without attachments');
    }

    await FlutterEmailSender.send(email);
  }

  Widget _getRuntimeIdForOS() => FutureBuilder(
      future: _cubits.repositories.session.thisRuntimeId,
      builder: (context, snapshot) {
        final runtimeId = snapshot.data ?? '';
        final runtimeIdWidget = Text(runtimeId,
            overflow: TextOverflow.ellipsis,
            style: context.theme.appTextStyle.bodySmall);

        if (Platform.isIOS) {
          return Expanded(
            child: Row(children: [Expanded(child: runtimeIdWidget)]),
          );
        }

        return runtimeIdWidget;
      });
}

const _externalNavigationIcon = Icon(Icons.open_in_browser);

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog();

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  FeedbackAttachments attachments = FeedbackAttachments(logs: true);

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Flex(direction: Axis.horizontal, children: [
            Fields.constrainedText(S.current.messageGoToMailApp,
                style: context.theme.appTextStyle.titleMedium, maxLines: 2)
          ]),
          content: CheckboxListTile(
            title: Text(S.current.labelAttachLogs,
                style: context.theme.appTextStyle.bodyMedium),
            value: attachments.logs,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  attachments = FeedbackAttachments(logs: value);
                });
              }
            },
          ),
          actions: [
            Fields.dialogActions(context, buttons: [
              NegativeButton(
                  text: S.current.actionCancel,
                  onPressed: () => Navigator.of(context).pop(null),
                  buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
              PositiveButton(
                  text: S.current.actionOK,
                  onPressed: () async => Navigator.of(context).pop(attachments),
                  buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
            ])
          ]);
}

class FeedbackAttachments {
  final bool logs;

  const FeedbackAttachments({required this.logs});
}
