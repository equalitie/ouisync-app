import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hex/hex.dart';
import 'package:locale_names/locale_names.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart'
    show
        ConnectivityInfo,
        LaunchAtStartupCubit,
        LocaleCubit,
        NatDetection,
        PeerSet,
        PeerSetCubit,
        PowerControl,
        ReposCubit,
        UpgradeExistsCubit;
import '../../pages/pages.dart' show LanguagePicker, PeersPage, WebViewPage;
import '../../utils/platform/platform.dart'
    show PlatformValues, PlatformWebView;
import '../../utils/utils.dart'
    show
        AppLogger,
        AppThemeExtension,
        Constants,
        Dialogs,
        dumpAll,
        Fields,
        formatSize,
        ThemeGetter;
import '../widgets.dart' show InfoBuble, NegativeButton, PositiveButton;
import 'app_version_tile.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class AboutSection extends SettingsSection with AppLogger {
  AboutSection(
    this.session, {
    required this.localeCubit,
    required this.powerControl,
    required this.reposCubit,
    required this.connectivityInfo,
    required this.peerSet,
    required this.natDetection,
    required this.launchAtStartup,
    required this.upgradeExists,
  }) : super(
          key: GlobalKey(debugLabel: 'key_about_section'),
          title: S.current.titleAbout,
        );

  final Session session;
  final LocaleCubit localeCubit;
  final PowerControl powerControl;
  final ReposCubit reposCubit;
  final ConnectivityInfo connectivityInfo;
  final PeerSetCubit peerSet;
  final NatDetection natDetection;
  final LaunchAtStartupCubit launchAtStartup;
  final UpgradeExistsCubit upgradeExists;

  TextStyle? bodyStyle;

  @override
  List<Widget> buildTiles(BuildContext context) {
    bodyStyle = context.theme.appTextStyle.bodyMedium;

    final currentLocale = localeCubit.currentLocale;
    final currentLanguage = StringBuffer(currentLocale.defaultDisplayLanguage);

    if (currentLocale == localeCubit.deviceLocale) {
      currentLanguage.write(' (${S.current.languageOfTheDevice})');
    }

    return [
      if (PlatformValues.isDesktopDevice)
        BlocBuilder<LaunchAtStartupCubit, bool>(
          bloc: launchAtStartup,
          builder: (context, state) => SwitchSettingsTile(
            value: state,
            onChanged: (value) => unawaited(launchAtStartup.setEnabled(value)),
            title: Text(
              S.current.messageLaunchAtStartup,
              style: bodyStyle,
            ),
            leading: Icon(Icons.rocket_launch_sharp),
          ),
        ),
      NavigationTile(
        title: Text(S.current.titleApplicationLanguage, style: bodyStyle),
        leading: Icon(Icons.language_rounded),
        value: Text(currentLanguage.toString(),
            style: context.theme.appTextStyle.bodySmall),
        onTap: () => _navigateToLanguagePicker(context),
      ),
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
        session: session,
        upgradeExists: upgradeExists,
        leading: Icon(Icons.info_rounded),
        title: Text(S.current.labelAppVersion, style: bodyStyle),
      ),
      SettingsTile(
        title: BlocBuilder<PeerSetCubit, PeerSet>(
            bloc: peerSet,
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

  @override
  bool containsErrorNotification() => upgradeExists.state;

  Future<void> _navigateToLanguagePicker(BuildContext context) async {
    await Navigator.of(context).push<Locale>(
      MaterialPageRoute(
        builder: (_) => LanguagePicker(
          localeCubit: localeCubit,
          canPop: true,
        ),
      ),
    );

    await S.delegate.load(localeCubit.currentLocale);
  }

  void _navigateToPeers(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PeersPage(session, peerSet),
        ),
      );

  Future<void> _openUrl(BuildContext context, String title, String url) async {
    final webView = PlatformWebView();

    if (PlatformValues.isMobileDevice) {
      final pageTitle = Text(title);

      await Dialogs.executeWithLoadingDialog(
        null,
        () async {
          final content = await webView.loadUrl(context, url);

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(
                title: pageTitle,
                content: content,
              ),
            ),
          );
        },
      );
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
        dumpAll(
          context,
          rootMonitor: reposCubit.rootStateMonitor,
          powerControl: powerControl,
          connectivityInfo: connectivityInfo,
          natDetection: natDetection,
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

  Future<void> _sendFeedback(io.File? logs) async {
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

  Widget _getRuntimeIdForOS() => FutureBuilder<PublicRuntimeId>(
      future: session.getRuntimeId(),
      builder: (context, snapshot) {
        final runtimeId = snapshot.data;
        final runtimeIdWidget = Text(
          runtimeId != null ? HEX.encode(runtimeId.value) : '',
          overflow: TextOverflow.ellipsis,
          style: context.theme.appTextStyle.bodySmall,
        );

        if (io.Platform.isIOS) {
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
            Fields.dialogActions(buttons: [
              NegativeButton(
                text: S.current.actionCancel,
                onPressed: () async =>
                    await Navigator.of(context).maybePop(null),
              ),
              PositiveButton(
                text: S.current.actionOK,
                onPressed: () async =>
                    await Navigator.of(context).maybePop(attachments),
              )
            ])
          ]);
}

class FeedbackAttachments {
  final bool logs;

  const FeedbackAttachments({required this.logs});
}
