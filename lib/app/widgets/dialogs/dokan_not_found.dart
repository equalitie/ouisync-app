import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart' show AppThemeExtension, Fields, ThemeGetter;
import '../widgets.dart' show NegativeButton, PositiveButton;

class DokanNotFound extends StatelessWidget {
  const DokanNotFound({
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
                TextSpan(text: '${S.current.messageInstallDokanForOuisyncP1} '),
                linkLaunchDokanGitHub,
                TextSpan(text: ' ${S.current.messageInstallDokanForOuisyncP2}')
              ],
            ),
          ),
          Fields.dialogActions(buttons: buildActions(context)),
        ],
      );

  List<Widget> buildActions(BuildContext context) => [
        NegativeButton(
          text: S.current.actionSkip.toLowerCase(),
          onPressed: () => Navigator.of(context).maybePop(false),
        ),
        PositiveButton(
          text: S.current.actionInstallDokan.toUpperCase(),
          onPressed: () => Navigator.of(context).maybePop(true),
        ),
      ];
}
