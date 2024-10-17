import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepoListState extends StatelessWidget
    with AppLogger, RepositoryActionsMixin {
  const RepoListState({
    required this.reposCubit,
    required this.bottomSheetInfo,
    required this.onShowRepoSettings,
  });

  final ReposCubit reposCubit;
  final ValueNotifier<BottomSheetInfo> bottomSheetInfo;

  final Future<void> Function(BuildContext context,
      {required RepoCubit repoCubit}) onShowRepoSettings;

  @override
  Widget build(BuildContext context) {
    if (reposCubit.currentRepo is LoadingRepoEntry) {
      return Container();
    }

    final repoList = reposCubit.repos.toList();
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Divider(height: 1),
          Expanded(
            child: _buildRepoList(
              context,
              repoList,
              reposCubit.currentRepoName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoList(
    BuildContext parentContext,
    List<RepoEntry> reposList,
    String? currentRepoName,
  ) =>
      ValueListenableBuilder(
        valueListenable: bottomSheetInfo,
        builder: (context, btInfo, child) => ListView.separated(
          padding: EdgeInsetsDirectional.only(
            bottom: btInfo.neededPadding <= 0.0
                ? Dimensions.defaultListBottomPadding
                : btInfo.neededPadding,
          ),
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
              mainAction: () async => await reposCubit.setCurrent(repoEntry),
              verticalDotsAction: () => onShowRepoSettings(
                parentContext,
                repoCubit: repoCubit,
              ),
            );
          },
        ),
      );
}
