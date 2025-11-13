import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class NoRepositoriesState extends StatefulWidget {
  const NoRepositoriesState({
    required this.directionality,
    required this.onCreateRepoPressed,
    required this.onImportRepoPressed,
  });

  final TextDirection directionality;
  final Future<void> Function() onCreateRepoPressed;
  final Future<void> Function() onImportRepoPressed;

  @override
  State<NoRepositoriesState> createState() => _NoRepositoriesStateState();
}

class _NoRepositoriesStateState extends State<NoRepositoriesState> {
  final newRepoButtonFocus = FocusNode(debugLabel: 'new_repo_button_focus');
  final importRepoButtonFocus = FocusNode(
    debugLabel: 'import_repo_button_focus',
  );

  @override
  void dispose() {
    super.dispose();

    newRepoButtonFocus.dispose();
    importRepoButtonFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nothingHereYetImageHeight =
        MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    return Directionality(
      textDirection: widget.directionality,
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
                onPressed: widget.onCreateRepoPressed,
                text: S.current.actionCreateRepository,
                size: Dimensions.sizeInPageButtonRegular,
                focusNode: newRepoButtonFocus,
                autofocus: true,
              ),
              Dimensions.spacingVertical,
              Fields.inPageButton(
                onPressed: widget.onImportRepoPressed,
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
