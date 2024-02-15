import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';

class NoRepositoriesState extends HookWidget {
  const NoRepositoriesState(
      {required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed});

  final Future<RepoLocation?> Function() onNewRepositoryPressed;
  final Future<RepoLocation?> Function() onImportRepositoryPressed;

  @override
  Widget build(BuildContext context) {
    final nothingHereYetImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    final newRepoButtonFocus =
        useFocusNode(debugLabel: 'new_repo_button_focus');
    final importRepoButtonFocus =
        useFocusNode(debugLabel: 'import_repo_button_focus');

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
              assetHeight: nothingHereYetImageHeight,
            ),
          ),
          Dimensions.spacingVerticalDouble,
          Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(
              S.current.messageNoRepos,
              style: context.theme.appTextStyle.bodyLarge,
            ),
          ),
          Dimensions.spacingVertical,
          Align(
            alignment: Alignment.center,
            child: Fields.inPageSecondaryMessage(
              S.current.messageCreateNewRepo,
              tags: {Constants.inlineTextBold: InlineTextStyles.bold},
            ),
          ),
          Dimensions.spacingVerticalDouble,
          Dimensions.spacingVerticalDouble,
          Fields.inPageButton(
            onPressed: () async => await onNewRepositoryPressed.call(),
            text: S.current.actionCreateRepository,
            size: Dimensions.sizeInPageButtonRegular,
            focusNode: newRepoButtonFocus,
            autofocus: true,
          ),
          Dimensions.spacingVertical,
          Fields.inPageButton(
            onPressed: () async => await onImportRepositoryPressed.call(),
            text: S.current.actionAddRepositoryWithToken,
            size: Dimensions.sizeInPageButtonRegular,
            focusNode: importRepoButtonFocus,
          ),
        ],
      ),
    ));
  }
}
