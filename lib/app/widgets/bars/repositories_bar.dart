import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class RepositoriesBar extends StatelessWidget
    with AppLogger
    implements PreferredSizeWidget {
  const RepositoriesBar(this._cubits);

  final Cubits _cubits;

  @override
  Widget build(BuildContext context) => _cubits.repositories.builder((state) {
        if (state.isLoading) {
          return Column(
            children: const [CircularProgressIndicator(color: Colors.white)],
          );
        }

        if (_cubits.repositories.showList) {
          return SizedBox.shrink();
        }

        final repo = state.currentRepo;
        IconData icon;

        if (repo == null) {
          icon = Fields.accessModeIcon(null);
        } else {
          icon = Fields.accessModeIcon(repo.accessMode);
        }

        return _buildState(context, repo, icon: icon);
      });

  String _repoName(RepoEntry? repo) {
    if (repo != null) {
      return repo.name;
    } else {
      return S.current.messageNoRepos;
    }
  }

  Widget _buildState(
    BuildContext context,
    RepoEntry? entry, {
    required IconData icon,
  }) =>
      Row(
        children: [
          _buildBackButton(),
          Expanded(
            child: Row(
              children: [
                Fields.constrainedText(
                  _repoName(entry),
                  softWrap: false,
                  textOverflow: TextOverflow.fade,
                ),
                IconButton(
                  icon: Icon(icon),
                  iconSize: Dimensions.sizeIconSmall,
                  onPressed: () => entry?.cubit?.lock(),
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildBackButton() {
    return multiBlocBuilder(
        [_cubits.upgradeExists, _cubits.powerControl, _cubits.panicCounter],
        () {
      final button = Fields.actionIcon(
        const Icon(Icons.arrow_back_rounded),
        onPressed: () => _cubits.repositories.showRepoList(),
        size: Dimensions.sizeIconSmall,
      );

      Color? color = _cubits.mainNotificationBadgeColor();

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
