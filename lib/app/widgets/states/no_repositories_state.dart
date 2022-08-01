import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
//import '../../cubits/cubits.dart';
import '../../utils/utils.dart';

class NoRepositoriesState extends StatelessWidget {
  const NoRepositoriesState({
    required this.onNewRepositoryPressed,
    required this.onAddRepositoryPressed
  });

  final Function() onNewRepositoryPressed;
  final Function() onAddRepositoryPressed;

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
              onPressed: () => onNewRepositoryPressed(),
              text: S.current.actionCreateRepository,
              size: Dimensions.sizeInPageButtonLong,
              autofocus: true
            ),
            Dimensions.spacingVerticalDouble,
            Fields.inPageButton(
              onPressed: () => onAddRepositoryPressed(),
              text: S.current.actionAddRepositoryWithToken,
              size: Dimensions.sizeInPageButtonLong,
            ),
          ],
        ),
      )
    );
  }
}
