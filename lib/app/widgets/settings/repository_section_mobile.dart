import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../models/repo_entry.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'navigation_tile_mobile.dart';
import 'repository_selector.dart';

class RepositorySectionMobile extends AbstractSettingsSection
    with RepositoryActionsMixin, OuiSyncAppLogger {
  final ReposCubit repos;
  final Future<void> Function(BuildContext) onRenameRepository;
  final Future<String?> Function(dynamic context) onRepositorySecurity;
  final Future<void> Function(dynamic context) onDeleteRepository;

  RepositorySectionMobile(
      {required this.repos,
      required this.onRenameRepository,
      required this.onRepositorySecurity,
      required this.onDeleteRepository});

  @override
  Widget build(BuildContext context) => repos.builder(
        (repos) => SettingsSection(
          title: Text(S.current.titleRepository),
          tiles: [
            SettingsTile(title: RepositorySelector(repos)),
            _buildCurrentTile(context, _buildDhtSwitch),
            _buildCurrentTile(context, _buildPexSwitch),
            _buildCurrentTile(context, _buildRenameTile),
            _buildCurrentTile(context, _buildShareTile),
            _buildCurrentTile(context, _buildSecurityTile),
            _buildCurrentTile(context, _buildDeleteTile),
          ],
        ),
      );

  AbstractSettingsTile _buildCurrentTile(
      BuildContext context, Widget Function(BuildContext, RepoCubit) builder) {
    final currentRepo = repos.currentRepo;
    final widget = currentRepo is OpenRepoEntry
        ? BlocBuilder<RepoCubit, RepoState>(
            bloc: currentRepo.cubit,
            builder: (context, state) => builder(context, currentRepo.cubit))
        : SizedBox.shrink();

    return CustomSettingsTile(child: widget);
  }

  Widget _buildDhtSwitch(
    BuildContext context,
    RepoCubit repo,
  ) =>
      PlatformDhtSwitch(
          repository: repo,
          title: S.current.labelBitTorrentDHT,
          icon: Icons.hub,
          onToggle: (value) => repo.setDhtEnabled(value));

  Widget _buildPexSwitch(
    BuildContext context,
    RepoCubit repo,
  ) =>
      PlatformPexSwitch(
          repository: repo,
          title: S.current.messagePeerExchange,
          icon: Icons.group_add,
          onToggle: (value) => repo.setPexEnabled(value));

  Widget _buildRenameTile(BuildContext context, _) => PlatformTappableTile(
      title: Text(S.current.actionRename),
      icon: Icons.edit,
      onTap: (context) async => await onRenameRepository(context));

  Widget _buildShareTile(BuildContext context, RepoCubit repo) =>
      PlatformTappableTile(
          title: Text(S.current.actionShare),
          icon: Icons.share,
          onTap: (_) async => shareRepository(context, repository: repo));

  Widget _buildSecurityTile(BuildContext parentContext, _) =>
      PlatformTappableTile(
          title: Text(S.current.titleSecurity),
          icon: Icons.password,
          onTap: (_) async => await onRepositorySecurity(parentContext));

  Widget _buildDeleteTile(BuildContext context, RepoCubit repo) =>
      NavigationTileMobile(
        title: Text(S.current.actionDelete,
            style: const TextStyle(color: Constants.dangerColor)),
        leading: Icon(Icons.delete, color: Constants.dangerColor),
        onPressed: (context) async => await onDeleteRepository(context),
      );
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
