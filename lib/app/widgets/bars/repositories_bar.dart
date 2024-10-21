import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import '../notification_badge.dart';
import '../throughput_display.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../repo_status.dart';

class RepositoriesBar extends StatelessWidget
    with AppLogger
    implements PreferredSizeWidget {
  const RepositoriesBar({
    required this.mount,
    required this.panicCounter,
    required this.powerControl,
    required this.reposCubit,
    required this.upgradeExists,
    super.key,
  });

  final MountCubit mount;
  final StateMonitorIntCubit panicCounter;
  final PowerControl powerControl;
  final ReposCubit reposCubit;
  final UpgradeExistsCubit upgradeExists;

  @override
  Widget build(BuildContext context) => reposCubit.builder((state) {
        if (reposCubit.isLoading || reposCubit.showList) {
          return SizedBox.shrink();
        }

        return Row(
          children: [
            _buildBackButton(),
            _buildName(reposCubit.currentRepo),
            _buildStats(context, reposCubit.currentRepo),
            _buildStatus(reposCubit.currentRepo),
            _buildLockButton(reposCubit.currentRepo),
          ],
        );
      });

  Widget _buildName(RepoEntry? repo) => Expanded(
        child: Container(
          padding: Dimensions.paddingItem,
          child: Text(
            repo?.name ?? S.current.messageNoRepos,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

  Widget _buildStats(BuildContext context, RepoEntry? repo) =>
      repo is OpenRepoEntry
          ? Padding(
              padding: EdgeInsetsDirectional.only(end: 10.0),
              child: LiveThroughputDisplay(
                _repoStatsStream(repo.cubit),
                size: Theme.of(context).textTheme.labelSmall?.fontSize,
                orientation: Orientation.portrait,
              ),
            )
          : SizedBox.shrink();

  Widget _buildStatus(RepoEntry? repo) => repo is OpenRepoEntry
      ? Padding(
          padding: EdgeInsetsDirectional.only(end: 10.0),
          child: RepoStatus(repo.cubit),
        )
      : SizedBox.shrink();

  Widget _buildLockButton(RepoEntry? repo) {
    final repoCubit = repo?.cubit;

    if (repoCubit != null) {
      return BlocBuilder<RepoCubit, RepoState>(
          bloc: repoCubit,
          builder: (context, state) => _buildLockButtonContent(repoCubit));
    } else {
      return _buildLockButtonContent(null);
    }
  }

  Widget _buildLockButtonContent(RepoCubit? repoCubit) => IconButton(
        icon: Icon(
            Fields.accessModeIcon(repoCubit?.accessMode ?? AccessMode.blind)),
        iconSize: Dimensions.sizeIconSmall,
        onPressed: () => repoCubit?.lock(),
        alignment: AlignmentDirectional.centerEnd,
      );

  // TODO: Why does the badge appear to move quickly after entering this screen?
  Widget _buildBackButton() => NotificationBadge(
        mount: mount,
        panicCounter: panicCounter,
        powerControl: powerControl,
        upgradeExists: upgradeExists,
        moveDownwards: 5,
        moveRight: 6,
        child: Fields.actionIcon(
          const Icon(Icons.arrow_back_rounded),
          onPressed: () => reposCubit.showRepoList(),
          size: Dimensions.sizeIconSmall,
        ),
      );

  @override
  Size get preferredSize {
    // TODO: This value was found experimentally, can it be done programmatically?
    return const Size.fromHeight(Constants.repositoryBarHeight);
  }
}

Stream<NetworkStats> _repoStatsStream(RepoCubit repoCubit) =>
    Stream.periodic(Duration(seconds: 1))
        .asyncMapSample((_) => repoCubit.networkStats);
