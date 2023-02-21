import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../app_version_tile.dart';
import 'desktop_settings.dart';

class AboutDesktopDetail extends StatelessWidget {
  const AboutDesktopDetail({required this.item, required this.reposCubit});

  final SettingItem item;
  final ReposCubit reposCubit;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildAppVersionTile(),
      Divider(height: 30.0),
      _buildRuntimeID(),
      Divider(height: 30.0)
    ]);
  }

  Widget _buildAppVersionTile() => AppVersionTile(
        session: reposCubit.session,
        leading: Icon(Icons.info_outline),
        title: Text(S.current.labelAppVersion),
      );

  Widget _buildRuntimeID() => ListTile(
      title: Text(S.current.messageSettingsRuntimeID),
      leading: Icon(Icons.person),
      subtitle: _getRuntimeIdForOS());

  Widget _getRuntimeIdForOS() {
    final runtimeId = Text(
      reposCubit.session.thisRuntimeId,
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
