import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class ErrorState extends HookWidget {
  const ErrorState({
    required this.directionality,
    required this.errorMessage,
    this.errorDescription,
    required this.onBackToList,
    super.key,
  });

  final TextDirection directionality;
  final String errorMessage;
  final String? errorDescription;

  final void Function()? onBackToList;

  @override
  Widget build(BuildContext context) {
    final reloadButtonFocus = useFocusNode(debugLabel: 'reload_button_focus');
    reloadButtonFocus.requestFocus();

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
                child: Fields.inPageMainMessage(
                  errorMessage,
                  style: context.theme.appTextStyle.bodyLarge
                      .copyWith(color: Constants.dangerColor),
                  tags: {
                    Constants.inlineTextColor:
                        InlineTextStyles.color(Colors.black),
                    Constants.inlineTextSize: InlineTextStyles.size(),
                    Constants.inlineTextBold: InlineTextStyles.bold
                  },
                ),
              ),
              if (errorDescription != null) const SizedBox(height: 10.0),
              if (errorDescription != null)
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Fields.inPageSecondaryMessage(
                    errorDescription!,
                    tags: {
                      Constants.inlineTextSize: InlineTextStyles.size(),
                      Constants.inlineTextBold: InlineTextStyles.bold,
                      Constants.inlineTextIcon:
                          InlineTextStyles.icon(Icons.south)
                    },
                  ),
                ),
              Dimensions.spacingVerticalDouble,
              Fields.inPageButton(
                onPressed: onBackToList,
                text: S.current.actionBack,
                focusNode: reloadButtonFocus,
                autofocus: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
