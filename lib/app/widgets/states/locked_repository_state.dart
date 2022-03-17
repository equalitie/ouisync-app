import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class LockedRepositoryState extends StatelessWidget {
  const LockedRepositoryState({
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
              Strings.messageLockedRepository,
              tags: {
                Constants.inlineTextColor: InlineTextStyles.color(Colors.black),
                Constants.inlineTextSize: InlineTextStyles.size(),
                Constants.inlineTextBold: InlineTextStyles.bold
              }
            )
          ),
          SizedBox(height: 10.0),
          Align(
            alignment: Alignment.center,
            child: Fields.inPageSecondaryMessage(
              Strings.messageInputPasswordToUnlock,
              tags: {
                Constants.inlineTextSize: InlineTextStyles.size(),
                Constants.inlineTextBold: InlineTextStyles.bold,
              }
            )
          ),
          SizedBox(height: 20.0),
          Fields.inPageButton(
            onPressed: () { onUnlockPressed!.call(this.repositoryName); },
            text: Strings.actionUnlock,
            autofocus: true
          )
        ],
      ),
    );
  }
}