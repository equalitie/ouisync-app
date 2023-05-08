import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepoListState extends StatelessWidget {
  const RepoListState(
      {required this.reposCubit,
      required this.bottomPaddingWithBottomSheet,
      required this.onCheckForBiometrics,
      required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed,
      required this.onGetAuthenticationMode,
      required this.onTryGetSecurePassword});

  final ReposCubit reposCubit;
  final ValueNotifier<double> bottomPaddingWithBottomSheet;

  final Future<bool?> Function() onCheckForBiometrics;
  final Future<String?> Function() onNewRepositoryPressed;
  final Future<String?> Function() onImportRepositoryPressed;
  final String? Function(String repoName) onGetAuthenticationMode;
  final Future<String?> Function(
      {required BuildContext context,
      required String databaseId,
      required String authenticationMode}) onTryGetSecurePassword;

  @override
  Widget build(BuildContext context) {
    if (reposCubit.currentRepo is LoadingRepoEntry) {
      return Container();
    }

    final repoList = reposCubit.repos.toList();

    if (repoList.isNotEmpty) {
      return _buildRepoList(context, repoList, reposCubit.currentRepoName);
    }

    return NoRepositoriesState(
        onNewRepositoryPressed: onNewRepositoryPressed,
        onImportRepositoryPressed: onImportRepositoryPressed);
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

                final repoItem = RepoItem(
                    name: repoEntry.name,
                    path: '',
                    accessMode: repoEntry.accessMode,
                    isDefault: isDefault);

                final listItem = ListItem(
                    repository: repoEntry.maybeCubit!,
                    itemData: repoItem,
                    mainAction: () async {
                      final repoName = repoEntry.name;

                      await reposCubit.setCurrentByName(repoName);
                      reposCubit.pushRepoList(false);
                    },
                    verticalDotsAction: () async {
                      final cubit = repoEntry.maybeCubit;
                      if (cubit == null) {
                        return;
                      }

                      await _showRepoSettings(parentContext,
                          repoCubit: cubit, data: repoItem);
                    });

                return listItem;
              }));

  Future<dynamic> _showRepoSettings(
    BuildContext context, {
    required RepoCubit repoCubit,
    required BaseItem data,
  }) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            return RepositorySettings(
                context: context,
                cubit: repoCubit,
                data: data as RepoItem,
                checkForBiometrics: onCheckForBiometrics,
                getAuthenticationMode: onGetAuthenticationMode,
                tryGetSecurePassword: onTryGetSecurePassword,
                renameRepository: reposCubit.renameRepository,
                deleteRepository: reposCubit.deleteRepository);
          });
}
