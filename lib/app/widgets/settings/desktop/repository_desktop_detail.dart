import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../../../models/models.dart';
import '../../widgets.dart';
import '../repository_selector.dart';

class RepositoryDesktopDetail extends StatelessWidget {
  RepositoryDesktopDetail(
      {required this.item,
      required this.reposCubit,
      required this.isBiometricsAvailable,
      required this.onRenameRepository,
      required this.onShareRepository});

  final SettingItem item;
  final ReposCubit reposCubit;
  final bool isBiometricsAvailable;

  final Future<void> Function(dynamic context) onRenameRepository;
  final void Function(RepoCubit) onShareRepository;

  @override
  Widget build(BuildContext context) => Column(children: [
        RepositorySelector(reposCubit),
        _buildTile(context, _buildDhtSwitch),
        _buildTile(context, _buildPeerExchangeSwitch),
        _buildTile(context, _buildRenameTile)
      ]);

  Widget _buildTile(
      BuildContext context, Widget Function(BuildContext, RepoCubit) builder) {
    final currentRepo = reposCubit.currentRepo;
    final widget = currentRepo is OpenRepoEntry
        ? currentRepo.cubit.builder((repo) => builder(context, repo))
        : SizedBox.shrink();

    return widget;
  }

  Widget _buildDhtSwitch(BuildContext context, RepoCubit repository) =>
      PlatformDhtSwitch(
          repository: repository,
          title: S.current.labelBitTorrentDHT,
          icon: Icons.hub);

  Widget _buildPeerExchangeSwitch(BuildContext context, RepoCubit repository) =>
      PlatformPeerExchangeSwitch(
          repository: repository,
          title: S.current.messagePeerExchange,
          icon: Icons.group_add);

  Widget _buildRenameTile(BuildContext context, RepoCubit repository) =>
      PlatformTappableTile(
          reposCubit: reposCubit,
          repoName: repository.name,
          title: S.current.actionRename,
          icon: Icons.edit,
          onTap: onRenameRepository);
}
