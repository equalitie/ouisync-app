import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class ErrorState extends StatefulWidget {
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
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState> {
  final reloadButtonFocus = FocusNode(debugLabel: 'reload_button_focus');

  @override
  void initState() {
    super.initState();
    reloadButtonFocus.requestFocus();
  }

  @override
  void dispose() {
    reloadButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
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
              child: Fields.inPageMainMessage(
                widget.errorMessage,
                style: context.theme.appTextStyle.bodyLarge.copyWith(
                  color: Constants.dangerColor,
                ),
                tags: {
                  Constants.inlineTextColor: InlineTextStyles.color(
                    Colors.black,
                  ),
                  Constants.inlineTextSize: InlineTextStyles.size(),
                  Constants.inlineTextBold: InlineTextStyles.bold,
                },
              ),
            ),
            if (widget.errorDescription != null) const SizedBox(height: 10.0),
            if (widget.errorDescription != null)
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.inPageSecondaryMessage(
                  widget.errorDescription!,
                  tags: {
                    Constants.inlineTextSize: InlineTextStyles.size(),
                    Constants.inlineTextBold: InlineTextStyles.bold,
                    Constants.inlineTextIcon: InlineTextStyles.icon(
                      Icons.south,
                    ),
                  },
                ),
              ),
            Dimensions.spacingVerticalDouble,
            Fields.inPageButton(
              onPressed: widget.onBackToList,
              text: S.current.actionBack,
              focusNode: reloadButtonFocus,
              autofocus: true,
            ),
          ],
        ),
      ),
    ),
  );
}
