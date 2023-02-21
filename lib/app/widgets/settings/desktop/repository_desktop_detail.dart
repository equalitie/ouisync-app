import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../../widgets.dart';
import '../repository_selector.dart';

class RepositoryDesktopDetail extends StatelessWidget {
  RepositoryDesktopDetail(
      {required this.item,
      required this.reposCubit,
      required this.isBiometricsAvailable,
      required this.onRenameRepository,
      required this.onShareRepository,
      required this.onRepositorySecurity,
      required this.onDeleteRepository});

  final SettingItem item;
  final ReposCubit reposCubit;
  final bool isBiometricsAvailable;

  final Future<void> Function(dynamic context) onRenameRepository;
  final void Function(RepoCubit) onShareRepository;
  final Future<void> Function(dynamic context) onRepositorySecurity;
  final Future<void> Function(dynamic context) onDeleteRepository;

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [RepositorySelector(reposCubit)]),
        SizedBox(height: 20.0),
        _buildTile(context, _buildDhtSwitch),
        Divider(height: 30.0),
        _buildTile(context, _buildPeerExchangeSwitch),
        Divider(height: 30.0),
        _buildTile(context, _buildRenameTile),
        _buildTile(context, _buildShareTile),
        Divider(height: 30.0),
        _buildTile(context, _buildSecurityTile),
        Divider(height: 30.0),
        _buildTile(context, _buildDeleteTile),
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
      PlatformSwitch(
          repository: repository,
          title: S.current.labelBitTorrentDHT,
          icon: Icons.hub,
          onToggle: (value) => repository.setDhtEnabled(value));

  Widget _buildPeerExchangeSwitch(BuildContext context, RepoCubit repository) =>
      PlatformSwitch(
          repository: repository,
          title: S.current.messagePeerExchange,
          icon: Icons.group_add,
          onToggle: (value) => repository.setPexEnabled(value));

  Widget _buildRenameTile(BuildContext context, RepoCubit repository) =>
      PlatformTappableTile(
          reposCubit: reposCubit,
          repoName: repository.name,
          title: S.current.actionRename,
          icon: Icons.edit,
          onTap: (_) async => await onRenameRepository(context));

  Widget _buildShareTile(BuildContext context, RepoCubit repository) =>
      PlatformTappableTile(
          reposCubit: reposCubit,
          repoName: repository.name,
          title: S.current.actionShare,
          icon: Icons.share,
          onTap: (_) => onShareRepository(repository));

  Widget _buildSecurityTile(BuildContext context, RepoCubit repository) =>
      RepositorySecurityDesktop(onRepositorySecurity: onRepositorySecurity);

  Widget _buildDeleteTile(BuildContext context, RepoCubit repository) =>
      Column(children: [
        Row(children: [Text('Delete', textAlign: TextAlign.start)]),
        ListTile(
            leading: const Icon(Icons.delete, color: Constants.dangerColor),
            title: Row(children: [
              TextButton(
                  onPressed: () async => await onDeleteRepository(context),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      child: Text("Delete repository")),
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white))
            ]))
      ]);
}
