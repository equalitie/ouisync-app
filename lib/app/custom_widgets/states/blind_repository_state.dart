import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class BlindRepositoryState extends StatelessWidget {
  const BlindRepositoryState({
    Key? key,
    required this.repositoryName,
    required this.onUnlockPressed
  }) : super(key: key);

  final String repositoryName;
  final Function(String)? onUnlockPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingContents,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(
              Strings.messageBlindRepository,
            ),
          ),
          Dimensions.spacingVertical,
          Align(
            alignment: Alignment.center,
            child: Fields.inPageSecondaryMessage(
              Strings.messageBlindRepositoryContent,
              tags: {
                Constants.inlineTextBold: InlineTextStyles.bold,
                Constants.inlineTextIcon: InlineTextStyles.icon(
                  Icons.add_circle,
                  size: 34.0,
                  color: Theme.of(context).primaryColor
                )
              }
            ),
          ),
          Dimensions.spacingVerticalDouble,
          Fields.inPageButton(
            onPressed: () { onUnlockPressed!.call(this.repositoryName); },
            text: Strings.actionRetry,
            autofocus: true
          )
        ],
      ),
    );
  }
}
