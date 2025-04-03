import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show Stats;
import 'package:stream_transform/stream_transform.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../notification_badge.dart';
import '../widgets.dart';

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
  Widget build(BuildContext context) => BlocBuilder<ReposCubit, ReposState>(
        bloc: reposCubit,
        builder: (context, state) {
          if (state.isLoading || state.current == null) {
            return SizedBox.shrink();
          }

          final current = state.current;

          return Row(
            children: [
              _buildBackButton(),
              _buildName(context, current),
              _buildStats(context, current),
              _buildStatus(current),
              _buildLockButton(current),
            ],
          );
        },
      );

  Widget _buildName(BuildContext context, RepoEntry? repo) {
    final parentColor =
        context.theme.primaryTextTheme.titleMedium?.color ?? Colors.transparent;

    return Expanded(
      child: Container(
        padding: Dimensions.paddingItem,
        child: ScrollableTextWidget(
          child: Text(repo?.name ?? S.current.messageNoRepos),
          parentColor: parentColor,
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, RepoEntry? repo) =>
      repo is OpenRepoEntry
          ? Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: LiveThroughputDisplay(
                _repoStatsStream(repo.cubit),
                size: Theme.of(context).textTheme.labelSmall?.fontSize,
                orientation: Orientation.portrait,
              ),
            )
          : SizedBox.shrink();

  Widget _buildStatus(RepoEntry? repo) => repo is OpenRepoEntry
      ? Padding(
          padding: EdgeInsets.only(right: 10.0),
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
        key: Key('access-mode-button'),
        icon: Icon(
            Fields.accessModeIcon(repoCubit?.accessMode ?? AccessMode.blind)),
        iconSize: Dimensions.sizeIconSmall,
        onPressed: () => repoCubit?.lock(),
        alignment: Alignment.centerRight,
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

Stream<Stats> _repoStatsStream(RepoCubit repoCubit) =>
    Stream.periodic(Duration(seconds: 1))
        .asyncMapSample((_) => repoCubit.networkStats);
