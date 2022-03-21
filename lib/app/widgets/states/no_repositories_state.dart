import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubit/cubits.dart';
import '../../utils/utils.dart';

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
              child: Fields.inPageMainMessage(S.current.messageNoRepos),
            ),
            Dimensions.spacingVertical,
            Align(
              alignment: Alignment.center,
              child: Fields.inPageSecondaryMessage(
                S.current.messageCreateNewRepo,
                tags: { Constants.inlineTextBold: InlineTextStyles.bold }
              )
            ),
            Dimensions.spacingVerticalDouble,
            Dimensions.spacingVertical,
            Fields.inPageButton(
              onPressed: () => onNewRepositoryPressed.call(repositoriesCubit),
              text: S.current.actionCreateRepository,
              size: Dimensions.sizeInPageButtonLong,
              autofocus: true
            ),
            Dimensions.spacingVerticalDouble,
            Fields.inPageButton(
              onPressed: () => onAddRepositoryPressed(repositoriesCubit),
              text: S.current.actionAddRepositoryWithToken,
              size: Dimensions.sizeInPageButtonLong,
            ),
          ],
        ),
      )
    );
  }
}