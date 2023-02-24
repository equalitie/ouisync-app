import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/l10n.dart';
import '../../../cubits/cubits.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../../widgets.dart';
import '../repository_selector.dart';

class RepositoryDesktopDetail extends StatelessWidget {
  const RepositoryDesktopDetail(
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
  final Future<String?> Function(dynamic context) onRepositorySecurity;
  final Future<void> Function(dynamic context) onDeleteRepository;

  @override
  Widget build(BuildContext context) =>
      reposCubit.builder((repos) => Column(children: [
            Row(children: [RepositorySelector(reposCubit)]),
            SizedBox(height: 20.0),
            _buildTile(context, _buildDhtSwitch),
            _buildTile(context, _buildPeerExchangeSwitch),
            _buildTile(context, _buildRenameTile),
            _buildTile(context, _buildShareTile),
            _buildTile(context, _buildSecurityTile),
            _buildTile(context, _buildDeleteTile),
          ]));

  Widget _buildTile(
      BuildContext context, Widget Function(BuildContext, RepoCubit) builder) {
    final currentRepo = reposCubit.currentRepo;
    final widget = currentRepo is OpenRepoEntry
        ? BlocBuilder<RepoCubit, RepoState>(
            bloc: currentRepo.cubit,
            builder: (context, state) => builder(context, currentRepo.cubit))
        : SizedBox.shrink();

    return widget;
  }

  Widget _buildDhtSwitch(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        PlatformDhtSwitch(
            repository: repository,
            title: S.current.labelBitTorrentDHT,
            icon: Icons.hub,
            onToggle: (value) => repository.setDhtEnabled(value)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildPeerExchangeSwitch(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        PlatformPexSwitch(
            repository: repository,
            title: S.current.messagePeerExchange,
            icon: Icons.group_add,
            onToggle: (value) => repository.setPexEnabled(value)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildRenameTile(BuildContext context, RepoCubit repository) =>
      PlatformTappableTile(
          reposCubit: reposCubit,
          repoName: repository.name,
          title: S.current.actionRename,
          icon: Icons.edit,
          onTap: (_) async => await onRenameRepository(context));

  Widget _buildShareTile(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        PlatformTappableTile(
            reposCubit: reposCubit,
            repoName: repository.name,
            title: S.current.actionShare,
            icon: Icons.share,
            onTap: (_) => onShareRepository(repository)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildSecurityTile(BuildContext context, RepoCubit repository) =>
      Wrap(children: [
        /// TODO: Replace with commented code when desktop flow is in place
        PlatformTappableTile(
            reposCubit: reposCubit,
            repoName: repository.name,
            title: S.current.titleSecurity,
            icon: Icons.password,
            onTap: (_) async => await onRepositorySecurity(context)),
        Dimensions.desktopSettingDivider
      ]);
  // RepositorySecurityDesktop(onRepositorySecurity: onRepositorySecurity);

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
