import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/stage.dart';
import '../../utils/utils.dart' show AppThemeExtension, Fields, ThemeGetter;
import '../widgets.dart' show NegativeButton, PositiveButton;

class DokanDifferentMayorFound extends StatelessWidget {
  const DokanDifferentMayorFound({
    required this.stage,
    required this.linkLaunchDokanGitHub,
    super.key,
  });

  final Stage stage;
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
            TextSpan(text: ' ${S.current.messageDokanDifferentMayorP2}'),
          ],
        ),
      ),
      Fields.dialogActions(buttons: buildActions()),
    ],
  );

  List<Widget> buildActions() => [
    NegativeButton(
      text: S.current.actionSkip.toLowerCase(),
      onPressed: () => stage.maybePop(false),
    ),
    PositiveButton(
      text: S.current.actionInstallDokan.toUpperCase(),
      onPressed: () => stage.maybePop(true),
    ),
  ];
}
