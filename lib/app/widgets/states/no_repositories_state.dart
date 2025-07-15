import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class NoRepositoriesState extends HookWidget {
  const NoRepositoriesState({
    required this.directionality,
    required this.onCreateRepoPressed,
    required this.onImportRepoPressed,
  });

  final TextDirection directionality;
  final Future<void> Function() onCreateRepoPressed;
  final Future<void> Function() onImportRepoPressed;

  @override
  Widget build(BuildContext context) {
    final nothingHereYetImageHeight =
        MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    final newRepoButtonFocus = useFocusNode(
      debugLabel: 'new_repo_button_focus',
    );
    final importRepoButtonFocus = useFocusNode(
      debugLabel: 'import_repo_button_focus',
    );

    return Directionality(
      textDirection: directionality,
      child: Center(
        child: SingleChildScrollView(
          reverse: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.placeholderWidget(
                  assetName: Constants.assetPathNothingHereYet,
                  assetHeight: nothingHereYetImageHeight,
                ),
              ),
              Dimensions.spacingVerticalDouble,
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.inPageMainMessage(
                  S.current.messageNoRepos,
                  style: context.theme.appTextStyle.bodyLarge,
                ),
              ),
              Dimensions.spacingVertical,
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.inPageSecondaryMessage(
                  S.current.messageCreateNewRepo,
                  tags: {Constants.inlineTextBold: InlineTextStyles.bold},
                ),
              ),
              Dimensions.spacingVerticalDouble,
              Dimensions.spacingVerticalDouble,
              Fields.inPageButton(
                key: Key('create_first_repo'),
                onPressed: onCreateRepoPressed,
                text: S.current.actionCreateRepository,
                size: Dimensions.sizeInPageButtonRegular,
                focusNode: newRepoButtonFocus,
                autofocus: true,
              ),
              Dimensions.spacingVertical,
              Fields.inPageButton(
                onPressed: onImportRepoPressed,
                text: S.current.actionAddRepositoryWithToken,
                size: Dimensions.sizeInPageButtonRegular,
                focusNode: importRepoButtonFocus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
