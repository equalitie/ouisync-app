import 'dart:io';

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import 'app_version_tile.dart';

class AboutSection extends AbstractSettingsSection {
  final ReposCubit repos;

  AboutSection({required this.repos});

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: Text(S.current.titleAbout),
        tiles: [
          CustomSettingsTile(
            child: AppVersionTile(
              session: repos.session,
              leading: Icon(Icons.info_outline),
              title: Text(S.current.labelAppVersion),
            ),
          ),
          SettingsTile(
            title: Text(S.current.messageSettingsRuntimeID),
            leading: Icon(Icons.person),
            value: _getRuntimeIdForOS(),
          ),
        ],
      );

  Widget _getRuntimeIdForOS() {
    final runtimeId = Text(
      repos.session.thisRuntimeId,
      overflow: TextOverflow.ellipsis,
    );

    if (Platform.isIOS) {
      return Expanded(
          child: Row(
        children: [Expanded(child: runtimeId)],
      ));
    }

    return runtimeId;
  }
}
