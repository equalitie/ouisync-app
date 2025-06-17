import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' as oui;

import '../../../generated/l10n.dart';
import '../../cubits/repo.dart';
import '../../utils/utils.dart';

class NoContentsState extends StatelessWidget {
  const NoContentsState({
    required this.directionality,
    required this.repository,
    required this.path,
  });

  final TextDirection directionality;
  final RepoCubit repository;
  final String path;

  @override
  Widget build(BuildContext context) {
    final emptyFolderImageHeight =
        MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

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
                  assetName: Constants.assetEmptyFolder,
                  assetHeight: emptyFolderImageHeight,
                ),
              ),
              Dimensions.spacingVerticalDouble,
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.inPageMainMessage(
                  path.isEmpty
                      ? S.current.messageEmptyRepo
                      : S.current.messageEmptyFolder,
                  style: context.theme.appTextStyle.bodyLarge,
                ),
              ),
              Dimensions.spacingVertical,
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.inPageSecondaryMessage(
                  repository.state.accessMode == oui.AccessMode.write
                      ? S.current.messageCreateAddNewItem
                      : S.current.messageReadOnlyContents,
                  tags: {
                    Constants.inlineTextBold: InlineTextStyles.bold,
                    Constants.inlineTextIcon: InlineTextStyles.icon(
                      Icons.add_circle,
                      size: Dimensions.sizeIconBig,
                      color: Theme.of(context).primaryColor,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
