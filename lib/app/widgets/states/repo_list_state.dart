import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepoListState extends StatelessWidget {
  const RepoListState(
      {required this.reposCubit, required this.bottomPaddingWithBottomSheet});

  final ReposCubit reposCubit;
  final ValueNotifier<double> bottomPaddingWithBottomSheet;

  @override
  Widget build(BuildContext context) {
    final emptyFolderImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    if (reposCubit.currentRepo is LoadingRepoEntry) {
      return Container();
    }

    final repoList = reposCubit.repos.toList();

    return reposCubit.repos.isEmpty
        ? _buildPlaceholder(emptyFolderImageHeight)
        : _buildRepoList(repoList, reposCubit.currentRepoName);
  }

  Widget _buildPlaceholder(double emptyFolderImageHeight) => Center(
        child: SingleChildScrollView(
          reverse: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Fields.placeholderWidget(
                      assetName: Constants.assetEmptyFolder,
                      assetHeight: emptyFolderImageHeight)),
              Dimensions.spacingVerticalDouble,
              Align(
                alignment: Alignment.center,
                child:
                    Fields.inPageMainMessage(S.current.messageNothingHereYet),
              )
            ],
          ),
        ),
      );

  Widget _buildRepoList(List<RepoEntry> reposList, String? currentRepoName) =>
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

                final listItem = ListItem(
                  repository: repoEntry.maybeCubit!,
                  itemData: RepoItem(
                      name: repoEntry.name,
                      path: '',
                      accessMode: repoEntry.accessMode,
                      isDefault: isDefault),
                  mainAction: () async {
                    final repoName = repoEntry.name;

                    await reposCubit.setCurrentByName(repoName);
                    reposCubit.pushRepoList(false);
                  },
                  folderDotsAction: () async {},
                );

                return listItem;
              }));
}
