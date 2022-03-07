import 'package:flutter/material.dart';
import 'package:ouisync_app/app/cubit/cubits.dart';
import 'package:ouisync_app/app/utils/utils.dart';

class NoRepositoriesState extends StatelessWidget {
  const NoRepositoriesState({
    Key? key,
    required this.repositoriesCubit,
    required this.onNewRepositoryPressed,
    required this.onAddRepositoryPressed
  }) : super(key: key);

  final RepositoriesCubit repositoriesCubit;
  final Function(RepositoriesCubit) onNewRepositoryPressed;
  final Function(RepositoriesCubit) onAddRepositoryPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        reverse: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Fields.inPageMainMessage(Strings.messageNoRepos),
            ),
            Dimensions.spacingVertical,
            Align(
              alignment: Alignment.center,
              child: Fields.inPageSecondaryMessage(
                Strings.messageCreateNewRepo,
                tags: { Constants.inlineTextBold: InlineTextStyles.bold }
              )
            ),
            Dimensions.spacingVerticalDouble,
            Dimensions.spacingVertical,
            Fields.inPageButton(
              onPressed: () => onNewRepositoryPressed.call(repositoriesCubit),
              text: Strings.actionCreateRepository,
              size: Dimensions.sizeInPageButtonLong,
              autofocus: true
            ),
            Dimensions.spacingVerticalDouble,
            Fields.inPageButton(
              onPressed: () => onAddRepositoryPressed(repositoriesCubit),
              text: Strings.actionAddRepositoryWithToken,
              size: Dimensions.sizeInPageButtonLong,
            ),
          ],
        ),
      )
    );
  }
}