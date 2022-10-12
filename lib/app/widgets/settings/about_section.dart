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
          )
        ],
      );
}
