import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart'
    show AppThemeExtension, Dimensions, Fields, ThemeGetter;
import '../widgets.dart' show NegativeButton;

class DokanOlderMayorFound extends StatelessWidget {
  const DokanOlderMayorFound({
    required this.linkLaunchDokanGitHub,
    super.key,
  });

  final TextSpan linkLaunchDokanGitHub;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              style: context.theme.appTextStyle.bodyMedium,
              children: [
                TextSpan(text: '${S.current.messageDokanDifferentMayorP1} '),
                linkLaunchDokanGitHub,
                TextSpan(text: ' ${S.current.messageDokanOlderVersionP2}')
              ],
            ),
          ),
          Fields.dialogActions(buttons: buildActions(context)),
        ],
      );

  List<Widget> buildActions(BuildContext context) => [
        NegativeButton(
          text: S.current.actionCloseCapital,
          onPressed: () => Navigator.of(context).maybePop(false),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        ),
      ];
}
