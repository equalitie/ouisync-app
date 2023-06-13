import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../utils/constants.dart';

class RepositoriesBar extends StatelessWidget implements PreferredSizeWidget {
  const RepositoriesBar(
      {required this.reposCubit,
      required this.checkForBiometricsCallback,
      required this.getAuthenticationModeCallback,
      required this.setAuthenticationModeCallback});

  final ReposCubit reposCubit;

  final CheckForBiometricsFunction checkForBiometricsCallback;
  final AuthMode? Function(String repoName) getAuthenticationModeCallback;
  final Future<void> Function(String repoName, AuthMode? value)
      setAuthenticationModeCallback;

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
      reposCubit.builder((state) {
        if (state.isLoading) {
          return CircularProgressIndicator(color: Colors.white);
        }

        if (reposCubit.showList) {
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
      child: Row(children: [
        Expanded(child: Text(S.current.titleAppTitle)),

        /// TODO: Implement search repos in list
        // Fields.actionIcon(
        //   const Icon(Icons.search_rounded),
        //   onPressed: () {},
        //   size: Dimensions.sizeIconSmall,
        //   color: Colors.white,
        // )
      ]));

  Widget _buildState(
    BuildContext context, {
    required IconData icon,
    required String repoName,
  }) =>
      Row(children: [
        Fields.actionIcon(const Icon(Icons.arrow_back_rounded),
            onPressed: () => reposCubit.pushRepoList(true),
            size: Dimensions.sizeIconSmall),
        Expanded(
            child: Container(
                padding: Dimensions.paddingRepositoryPicker,
                child: Row(children: [
                  IconButton(
                      icon: Icon(icon),
                      iconSize: Dimensions.sizeIconSmall,
                      onPressed: () async {
                        if (reposCubit.currentRepo == null) return;

                        if (reposCubit.currentRepo?.accessMode ==
                            AccessMode.blind) return;

                        final repo = reposCubit.currentRepo;

                        if (repo is OpenRepoEntry) {
                          await reposCubit
                              .lockRepository(repo.settingsRepoEntry);
                        }
                      }),
                  Fields.constrainedText(repoName,
                      softWrap: false, textOverflow: TextOverflow.fade)
                ])))
      ]);

  @override
  Size get preferredSize {
    // TODO: This value was found experimentally, can it be done programmatically?
    return const Size.fromHeight(Constants.repositoryBarHeight);
  }
}
