import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../repo_status.dart';

class RepositoriesBar extends StatelessWidget
    with AppLogger
    implements PreferredSizeWidget {
  const RepositoriesBar({
    required this.cubits,
    required this.reposCubit,
    super.key,
  });

  final Cubits cubits;
  final ReposCubit reposCubit;

  @override
  Widget build(BuildContext context) => reposCubit.builder((state) {
        if (reposCubit.isLoading || reposCubit.showList) {
          return SizedBox.shrink();
        }

        return Row(
          children: [
            _buildBackButton(),
            _buildName(reposCubit.currentRepo),
            _buildStatus(reposCubit.currentRepo),
            _buildLockButton(reposCubit.currentRepo),
          ],
        );
      });

  Widget _buildName(RepoEntry? repo) => Expanded(
        child: Container(
          padding: Dimensions.paddingItem,
          child: Fields.ellipsedText(
            repo?.name ?? S.current.messageNoRepos,
            ellipsisPosition: TextOverflowPosition.middle,
          ),
        ),
      );

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
        icon: Icon(
            Fields.accessModeIcon(repoCubit?.accessMode ?? AccessMode.blind)),
        iconSize: Dimensions.sizeIconSmall,
        onPressed: () => repoCubit?.lock(),
        alignment: Alignment.centerRight,
      );

  Widget _buildBackButton() {
    return multiBlocBuilder(
        [cubits.upgradeExists, cubits.powerControl, cubits.panicCounter], () {
      final button = Fields.actionIcon(
        const Icon(Icons.arrow_back_rounded),
        onPressed: () => reposCubit.showRepoList(),
        size: Dimensions.sizeIconSmall,
      );

      Color? color = cubits.mainNotificationBadgeColor();

      if (color != null) {
        // TODO: Why does the badge appear to move quickly after entering this screen?
        return Fields.addBadge(button,
            color: color, moveDownwards: 5, moveRight: 6);
      } else {
        return button;
      }
    });
  }

  @override
  Size get preferredSize {
    // TODO: This value was found experimentally, can it be done programmatically?
    return const Size.fromHeight(Constants.repositoryBarHeight);
  }
}
