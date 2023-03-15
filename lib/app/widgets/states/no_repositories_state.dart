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
          Fields.inPageButton(
              onPressed: () async => await onNewRepositoryPressed.call(),
              leadingIcon: const Icon(Icons.add),
              text: S.current.actionCreateRepository,
              size: Dimensions.sizeInPageButtonLong,
              alignment: Alignment.centerLeft,
              autofocus: true),
          Dimensions.spacingVertical,
          Fields.inPageButton(
            onPressed: () async => await onImportRepositoryPressed.call(),
            leadingIcon: const Icon(Icons.add),
            text: S.current.actionAddRepositoryWithToken,
            size: Dimensions.sizeInPageButtonLong,
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    ));
  }
}
