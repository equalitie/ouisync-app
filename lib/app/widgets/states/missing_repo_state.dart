import 'package:flutter/material.dart';
import 'package:ouisync_app/app/widgets/widgets.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/repo_actions_mixin.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class MissingRepositoryState extends StatelessWidget
    with AppLogger, RepositoryActionsMixin {
  const MissingRepositoryState({
    required this.directionality,
    required this.repositoryLocation,
    required this.errorMessage,
    this.errorDescription,
    required this.onBackToList,
    required this.reposCubit,
    super.key,
  });

  final TextDirection directionality;
  final RepoLocation repositoryLocation;
  final String errorMessage;
  final String? errorDescription;
  final ReposCubit reposCubit;

  final void Function()? onBackToList;

  @override
  Widget build(BuildContext context) {
    final emptyFolderImageHeight =
        MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    return ObjectHolder(
      create: () => FocusNode(debugLabel: 'reload_button_focus'),
      dispose: (node) => node.dispose(),
      builder: (context, reloadButtonFocus) => Directionality(
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
                    assetName: Constants.assetEmptyFolder,
                    assetHeight: emptyFolderImageHeight,
                  ),
                ),
                Dimensions.spacingVerticalDouble,
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Fields.inPageMainMessage(
                    errorMessage,
                    style: context.theme.appTextStyle.bodyLarge.copyWith(
                      color: Constants.dangerColor,
                    ),
                  ),
                ),
                if (errorDescription != null) Dimensions.spacingVertical,
                if (errorDescription != null)
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Fields.inPageSecondaryMessage(
                      errorDescription!,
                      tags: {Constants.inlineTextBold: InlineTextStyles.bold},
                    ),
                  ),
                Dimensions.spacingVerticalDouble,
                Fields.inPageButton(
                  onPressed: onBackToList,
                  text: S.current.actionBack,
                  size: Dimensions.sizeInPageButtonLong,
                  alignment: AlignmentDirectional.center,
                  focusNode: reloadButtonFocus,
                  autofocus: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
