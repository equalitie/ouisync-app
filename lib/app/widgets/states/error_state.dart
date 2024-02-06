import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class ErrorState extends HookWidget {
  const ErrorState({
    required this.errorMessage,
    this.errorDescription,
    required this.onReload,
    super.key,
  });

  final String errorMessage;
  final String? errorDescription;

  final void Function()? onReload;

  @override
  Widget build(BuildContext context) {
    final reloadButtonFocus = useFocusNode(debugLabel: 'reload_button_focus');
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
                    alignment: Alignment.center,
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
                if (onReload != null) Dimensions.spacingVerticalDouble,
                if (onReload != null)
                  Fields.inPageButton(
                    onPressed: onReload,
                    text: S.current.actionReloadContents,
                    focusNode: reloadButtonFocus,
                    autofocus: true,
                  )
              ],
            )));
  }
}
