import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class LockedRepositoryState extends StatelessWidget {
  const LockedRepositoryState(
      {required this.repositoryName,
      required this.unlockRepositoryCallback,
      Key? key})
      : super(key: key);

  final String repositoryName;
  final Future<void> Function({required String repositoryName})
      unlockRepositoryCallback;

  @override
  Widget build(BuildContext context) {
    final lockedRepoImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    return Center(
        child: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.center,
            child: Fields.placeholderWidget(
                assetName: Constants.assetLockedRepository,
                assetHeight: lockedRepoImageHeight)),
        Dimensions.spacingVerticalDouble,
        Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(S.current.messageLockedRepository,
                tags: {
                  Constants.inlineTextColor:
                      InlineTextStyles.color(Colors.black),
                  Constants.inlineTextSize: InlineTextStyles.size(),
                  Constants.inlineTextBold: InlineTextStyles.bold
                })),
        Dimensions.spacingVertical,
        Align(
            alignment: Alignment.center,
            child: Fields.inPageSecondaryMessage(
                S.current.messageInputPasswordToUnlock,
                tags: {
                  Constants.inlineTextSize: InlineTextStyles.size(),
                  Constants.inlineTextBold: InlineTextStyles.bold,
                })),
        Dimensions.spacingVerticalDouble,
        Fields.inPageButton(
            onPressed: () async =>
                await unlockRepositoryCallback(repositoryName: repositoryName),
            leadingIcon: const Icon(Icons.lock_open_rounded),
            text: S.current.actionUnlock,
            autofocus: true)
      ],
    )));
  }
}
