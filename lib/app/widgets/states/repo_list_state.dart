import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
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

  final Future<void> Function(
    BuildContext context, {
    required RepoCubit repoCubit,
  })
  onShowRepoSettings;

  @override
  Widget build(BuildContext context) {
    if (reposCubit.state.current is LoadingRepoEntry) {
      return Container();
    }

    final repoList = reposCubit.state.repos.values.toList();

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
              reposCubit.state.current?.name,
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
  ) => ValueListenableBuilder(
    valueListenable: bottomSheetInfo,
    builder:
        (context, btInfo, child) => ListView.separated(
          padding: EdgeInsetsDirectional.only(
            bottom:
                btInfo.neededPadding <= 0.0
                    ? Dimensions.defaultListBottomPadding
                    : btInfo.neededPadding,
          ),
          separatorBuilder:
              (context, index) =>
                  const Divider(height: 1, color: Colors.transparent),
          itemCount: reposList.length,
          itemBuilder: (context, index) {
            final repoEntry = reposList.elementAt(index);
            final isDefault = currentRepoName == repoEntry.name;
            final repoCubit = repoEntry.cubit;

            if (repoCubit == null) {
              return MissingRepoListItem(
                location: repoEntry.location,
                mainAction: () {},
                verticalDotsAction: () async {
                  final currentRepoEntry = reposCubit.state.current;
                  if (currentRepoEntry == null) return;

                  final repoName = currentRepoEntry.name;
                  final location = currentRepoEntry.location;
                  final deleteRepoFuture = reposCubit.deleteRepository(
                    location,
                  );

                  final deleted = await deleteRepository(
                    context,
                    repoName: repoName,
                    deleteRepoFuture: deleteRepoFuture,
                  );

                  if (deleted == true) {
                    Navigator.of(context).pop();
                    showSnackBar(S.current.messageRepositoryDeleted(repoName));
                  }
                },
              );
            }

            return RepoListItem(
              repoCubit: repoCubit,
              isDefault: isDefault,
              mainAction: () => reposCubit.setCurrent(repoEntry),
              verticalDotsAction:
                  () => onShowRepoSettings(parentContext, repoCubit: repoCubit),
            );
          },
        ),
  );
}
