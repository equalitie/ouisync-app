import 'package:flutter/material.dart';

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
      required this.onShowRepoSettings,
      required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed});

  final ReposCubit reposCubit;
  final ValueNotifier<double> bottomPaddingWithBottomSheet;

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

  Widget _buildRepoList(
    BuildContext parentContext,
    List<RepoEntry> reposList,
    String? currentRepoName,
  ) =>
      ValueListenableBuilder(
        valueListenable: bottomPaddingWithBottomSheet,
        builder: (context, value, child) => ListView.separated(
          padding: EdgeInsets.only(bottom: value),
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            color: Colors.transparent,
          ),
          itemCount: reposList.length,
          itemBuilder: (context, index) {
            final repoEntry = reposList.elementAt(index);
            final isDefault = currentRepoName == repoEntry.name;
            final repoCubit = repoEntry.cubit;

            if (repoCubit == null) {
              return MissingRepoListItem(
                location: repoEntry.location,
                mainAction: () {},
                verticalDotsAction: () => deleteRepository(
                  context,
                  reposCubit: reposCubit,
                  repoLocation: repoEntry.location,
                ),
              );
            }

            return RepoListItem(
              repoCubit: repoCubit,
              isDefault: isDefault,
              mainAction: () async {
                await reposCubit.setCurrent(repoEntry);
              },
              verticalDotsAction: () =>
                  onShowRepoSettings(parentContext, repoCubit: repoCubit),
            );
          },
        ),
      );
}
