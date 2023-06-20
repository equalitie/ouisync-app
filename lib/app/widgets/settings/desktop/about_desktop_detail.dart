import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';
import '../../../utils/utils.dart';
import '../app_version_tile.dart';

class AboutDesktopDetail extends StatelessWidget {
  const AboutDesktopDetail({required this.reposCubit});

  final ReposCubit reposCubit;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildFAQTile(context),
      _buildAppVersionTile(),
      _buildRuntimeID()
    ]);
  }

  Widget _buildFAQTile(BuildContext context) => Wrap(children: [
        ListTile(
            title: Text(S.current.titleFAQShort,
                style: const TextStyle(fontSize: Dimensions.fontSmall)),
            leading: const Icon(Icons.question_answer_rounded),
            subtitle: Text(S.current.messageFAQ),
            trailing: const Icon(Icons.launch_rounded),
            onTap: () async =>
                await PlatformWebView().launchUrl(Constants.faqUrl)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildAppVersionTile() => Wrap(children: [
        AppVersionTile(
          session: reposCubit.session,
          leading: Icon(Icons.info_outline),
          title: Text(S.current.labelAppVersion,
              style: TextStyle(fontSize: Dimensions.fontSmall)),
        ),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildRuntimeID() => ListTile(
      title: Text(S.current.messageSettingsRuntimeID,
          style: TextStyle(fontSize: Dimensions.fontSmall)),
      leading: Icon(Icons.person),
      subtitle: _getRuntimeIdForOS());

  Widget _getRuntimeIdForOS() => FutureBuilder(
      future: reposCubit.session.thisRuntimeId,
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
}
