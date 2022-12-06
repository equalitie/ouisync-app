import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class MissingRepositoryState extends StatelessWidget {
  const MissingRepositoryState(
      {required this.errorMessage,
      this.errorDescription,
      required this.onReloadRepository,
      required this.onDeleteRepository,
      Key? key})
      : super(key: key);

  final String errorMessage;
  final String? errorDescription;

  final void Function()? onReloadRepository;
  final void Function()? onDeleteRepository;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      reverse: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child:
                Fields.inPageMainMessage(errorMessage), //'Repository missing'),
          ),
          if (errorDescription != null) Dimensions.spacingVertical,
          if (errorDescription != null)
            Align(
                alignment: Alignment.center,
                child: Fields.inPageSecondaryMessage(errorDescription!,
                    // 'We could not find this repository in your device.\n\n'
                    // 'If you recently moved this repository files, put them '
                    // 'back and reload the repository; otherwise just delete it.',
                    tags: {Constants.inlineTextBold: InlineTextStyles.bold})),
          Dimensions.spacingVerticalDouble,
          if (onReloadRepository != null)
            Fields.inPageButton(
                onPressed: () => onReloadRepository!(),
                text: 'Reload repository',
                size: Dimensions.sizeInPageButtonLong,
                alignment: Alignment.center,
                autofocus: true),
          if (onReloadRepository != null) Dimensions.spacingVertical,
          if (onDeleteRepository != null)
            Fields.inPageButton(
              onPressed: () => onDeleteRepository!(),
              text: 'Delete repository',
              size: Dimensions.sizeInPageButtonLong,
              alignment: Alignment.center,
            ),
        ],
      ),
    ));
  }
}
