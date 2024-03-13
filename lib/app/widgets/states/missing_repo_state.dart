import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../mixins/repo_actions_mixin.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class MissingRepositoryState extends HookWidget
    with AppLogger, RepositoryActionsMixin {
  const MissingRepositoryState({
    required this.repositoryLocation,
    required this.errorMessage,
    this.errorDescription,
    required this.onReloadRepository,
    required this.reposCubit,
    super.key,
  });

  final RepoLocation repositoryLocation;
  final String errorMessage;
  final String? errorDescription;
  final ReposCubit reposCubit;

  final void Function()? onReloadRepository;

  @override
  Widget build(BuildContext context) {
    final emptyFolderImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    final reloadButtonFocus = useFocusNode(debugLabel: 'reload_button_focus');
    final deleteButtonFocus = useFocusNode(debugLabel: 'delete_button_focus');

    reloadButtonFocus.requestFocus();

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
                  assetName: Constants.assetEmptyFolder,
                  assetHeight: emptyFolderImageHeight)),
          Dimensions.spacingVerticalDouble,
          Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(errorMessage,
                style: context.theme.appTextStyle.bodyLarge
                    .copyWith(color: Constants.dangerColor)),
          ),
          if (errorDescription != null) Dimensions.spacingVertical,
          if (errorDescription != null)
            Align(
                alignment: Alignment.center,
                child: Fields.inPageSecondaryMessage(errorDescription!,
                    tags: {Constants.inlineTextBold: InlineTextStyles.bold})),
          Dimensions.spacingVerticalDouble,
          if (onReloadRepository != null)
            Fields.inPageButton(
                onPressed: () => onReloadRepository!(),
                text: S.current.actionReloadRepo,
                size: Dimensions.sizeInPageButtonLong,
                alignment: Alignment.center,
                focusNode: reloadButtonFocus,
                autofocus: true),
          if (onReloadRepository != null) Dimensions.spacingVertical,
          Fields.inPageButton(
              onPressed: () => deleteRepository(context,
                  repositoryLocation: repositoryLocation,
                  reposCubit: reposCubit),
              text: S.current.actionRemoveRepo,
              size: Dimensions.sizeInPageButtonLong,
              alignment: Alignment.center,
              focusNode: deleteButtonFocus),
        ],
      ),
    ));
  }
}
