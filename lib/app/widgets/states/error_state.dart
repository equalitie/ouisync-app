import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/generated/l10n.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    Key? key,
    required this.message,
    required this.onReload
  }) : super(key: key);

  final String message;
  final void Function()? onReload;

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
              child: Fields.inPageMainMessage(
                S.current.messageErrorDefault,
                color: Colors.red,
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
                this.message,
                tags: {
                  Constants.inlineTextSize: InlineTextStyles.size(),
                  Constants.inlineTextBold: InlineTextStyles.bold,
                  Constants.inlineTextIcon: InlineTextStyles.icon(Icons.south)
                }
              )
            ),
            Dimensions.spacingVerticalDouble,
            Fields.inPageButton(
              onPressed: this.onReload,
              text: S.current.actionReloadContents,
              autofocus: true
            )
          ],
        )
      )
    );
  }
}