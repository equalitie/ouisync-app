import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class NoRepositoriesState extends StatelessWidget {
  const NoRepositoriesState(
      {required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed});

  final Future<String?> Function() onNewRepositoryPressed;
  final Future<String?> Function() onImportRepositoryPressed;

  @override
  Widget build(BuildContext context) {
    final nothingHereYetImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    return Center(
        child: SingleChildScrollView(
      reverse: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.center,
              child: Fields.placeholderWidget(
                  assetName: Constants.assetPathNothingHereYet,
                  assetHeight: nothingHereYetImageHeight)),
          Dimensions.spacingVerticalDouble,
          Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(S.current.messageNoRepos),
          ),
          Dimensions.spacingVertical,
          Align(
              alignment: Alignment.center,
              child: Fields.inPageSecondaryMessage(
                  S.current.messageCreateNewRepo,
                  tags: {Constants.inlineTextBold: InlineTextStyles.bold})),
          Dimensions.spacingVerticalDouble,
          Dimensions.spacingVerticalDouble,
          Fields.inPageButton(
              onPressed: () async => await onNewRepositoryPressed.call(),
              text: S.current.actionCreateRepository,
              fontSize: Dimensions.fontMicro,
              size: Dimensions.sizeInPageButtonRegular,
              autofocus: true),
          Dimensions.spacingVertical,
          Fields.inPageButton(
              onPressed: () async => await onImportRepositoryPressed.call(),
              text: S.current.actionAddRepositoryWithToken,
              fontSize: Dimensions.fontMicro,
              size: Dimensions.sizeInPageButtonRegular),
        ],
      ),
    ));
  }
}
