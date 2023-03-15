import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../widgets.dart';

class RepoListState extends StatelessWidget {
  const RepoListState(
      {required this.reposCubit,
      required this.bottomPaddingWithBottomSheet,
      required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed});

  final ReposCubit reposCubit;
  final ValueNotifier<double> bottomPaddingWithBottomSheet;

  final Future<String?> Function() onNewRepositoryPressed;
  final Future<String?> Function() onImportRepositoryPressed;

  @override
  Widget build(BuildContext context) {
    if (reposCubit.currentRepo is LoadingRepoEntry) {
      return Container();
    }

    final repoList = reposCubit.repos.toList();

    if (repoList.isNotEmpty) {
      return _buildRepoList(repoList, reposCubit.currentRepoName);
    }

    return NoRepositoriesState(
        onNewRepositoryPressed: onNewRepositoryPressed,
        onImportRepositoryPressed: onImportRepositoryPressed);
  }

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
