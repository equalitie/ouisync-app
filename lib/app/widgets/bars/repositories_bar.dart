import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../utils/platform/platform.dart';

class RepositoriesBar extends StatelessWidget implements PreferredSizeWidget {
  const RepositoriesBar(this._cubits);

  final Cubits _cubits;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(
                width: 1.0,
                color: Colors.transparent,
                style: BorderStyle.solid),
          ),
        ),
        padding: Dimensions.paddingRepositoryBar,
        child: _buildRepoDescription(context));
  }

  Widget _buildRepoDescription(BuildContext context) =>
      _cubits.repositories.builder((state) {
        if (state.isLoading) {
          return Column(
            children: const [CircularProgressIndicator(color: Colors.white)],
          );
        }

        if (_cubits.repositories.showList) {
          return _buildRepoListState(context);
        }

        final repo = state.currentRepo;
        final name = _repoName(repo);

        if (repo == null) {
          return _buildState(
            context,
            icon: Fields.accessModeIcon(null),
            repoName: name,
          );
        }

        final icon = Fields.accessModeIcon(repo.accessMode);

        return _buildState(
          context,
          icon: icon,
          repoName: name,
        );
      });

  String _repoName(RepoEntry? repo) {
    if (repo != null) {
      return repo.name;
    } else {
      return S.current.messageNoRepos;
    }
  }

  Widget _buildRepoListState(BuildContext context) => Container(
      padding: Dimensions.paddingRepositoryPicker,
      child: Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Row(children: [
            Expanded(child: Text(S.current.titleRepositoriesList)),

            /// TODO: Implement search repos in list
            // Fields.actionIcon(
            //   const Icon(Icons.search_rounded),
            //   onPressed: () {},
            //   size: Dimensions.sizeIconSmall,
            //   color: Colors.white,
            // )
          ])));

  Widget _buildState(
    BuildContext context, {
    required IconData icon,
    required String repoName,
  }) =>
      Row(children: [
        _buildBackButton(),
        Expanded(
            child: Container(
                padding: Dimensions.paddingRepositoryPicker,
                child: Row(children: [
                  IconButton(
                      icon: Icon(icon),
                      iconSize: Dimensions.sizeIconSmall,
                      onPressed: () async {
                        if (_cubits.repositories.currentRepo == null) return;

                        if (_cubits.repositories.currentRepo?.accessMode ==
                            AccessMode.blind) return;

                        final repo = _cubits.repositories.currentRepo;

                        if (repo is OpenRepoEntry) {
                          await _cubits.repositories
                              .lockRepository(repo.settingsRepoEntry);
                        }
                      }),
                  Fields.constrainedText(repoName,
                      softWrap: false, textOverflow: TextOverflow.fade)
                ])))
      ]);

  Widget _buildBackButton() {
    return multiBlocBuilder(
        [_cubits.upgradeExists, _cubits.powerControl, _cubits.panicCounter],
        () {
      final button = Fields.actionIcon(const Icon(Icons.arrow_back_rounded),
          onPressed: () => _cubits.repositories.pushRepoList(true),
          size: Dimensions.sizeIconSmall);

      if (PlatformValues.isDesktopDevice) {
        // At time of writing this function we also have the gear settings
        // button on this page which shows the badge notification, so no need
        // to show it again on the back button.
        return button;
      }

      Color? color = _cubits.mainNotificationBadgeColor();

      if (color != null) {
        // TODO: Why does the badge appear to move quickly after entering this screen?
        return Fields.addBadge(button,
            color: color, moveDownwards: 3, moveRight: 3);
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
