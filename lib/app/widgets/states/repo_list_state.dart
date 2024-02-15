import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepoListState extends StatelessWidget
    with AppLogger, RepositoryActionsMixin {
  const RepoListState(
      {required this.reposCubit,
      required this.bottomPaddingWithBottomSheet,
      required this.settings,
      required this.onShowRepoSettings,
      required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed});

  final ReposCubit reposCubit;
  final ValueNotifier<double> bottomPaddingWithBottomSheet;

  final Settings settings;
  final Future<void> Function(BuildContext context,
      {required RepoCubit repoCubit}) onShowRepoSettings;
  final Future<RepoLocation?> Function() onNewRepositoryPressed;
  final Future<RepoLocation?> Function() onImportRepositoryPressed;

  @override
  Widget build(BuildContext context) {
    if (reposCubit.currentRepo is LoadingRepoEntry) {
      return Container();
    }

    final repoList = reposCubit.repos.toList();
    return _buildRepoList(context, repoList, reposCubit.currentRepoName);
  }

  Widget _buildRepoList(BuildContext parentContext, List<RepoEntry> reposList,
          String? currentRepoName) =>
      ValueListenableBuilder(
          valueListenable: bottomPaddingWithBottomSheet,
          builder: (context, value, child) => ListView.separated(
              padding: EdgeInsets.only(bottom: value),
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.transparent),
              itemCount: reposList.length,
              itemBuilder: (context, index) {
                final repoEntry = reposList.elementAt(index);
                bool isDefault = currentRepoName == repoEntry.name;

                if (repoEntry.maybeCubit == null) {
                  final repoMissingItem = RepoMissingItem(repoEntry.location,
                      message: S.current.messageRepoMissing);

                  return ListItem(
                      reposCubit: null,
                      repository: null,
                      itemData: repoMissingItem,
                      mainAction: () {},
                      verticalDotsAction: () async => deleteRepository(context,
                          repositoryLocation: repoEntry.location,
                          settings: settings,
                          reposCubit: reposCubit));
                }

                final repoItem = RepoItem(repoEntry.location,
                    accessMode: repoEntry.accessMode, isDefault: isDefault);

                final listItem = ListItem(
                    reposCubit: reposCubit,
                    repository: repoEntry.maybeCubit!,
                    itemData: repoItem,
                    mainAction: () async {
                      await reposCubit.setCurrentByLocation(repoEntry.location);
                    },
                    verticalDotsAction: () async {
                      final cubit = repoEntry.maybeCubit;
                      if (cubit == null) {
                        return;
                      }

                      await onShowRepoSettings(parentContext, repoCubit: cubit);
                    });

                return listItem;
              }));
}
