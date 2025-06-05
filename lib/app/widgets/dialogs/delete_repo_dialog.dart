import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart'
    show AppThemeExtension, Dimensions, Fields, ThemeGetter;
import '../widgets.dart' show NegativeButton, PositiveButton;

class DeleteRepoDialog extends StatefulWidget {
  const DeleteRepoDialog({required this.repoName, super.key});

  final String repoName;

  @override
  State<DeleteRepoDialog> createState() => _DeleteRepoDialogState();
}

class _DeleteRepoDialogState extends State<DeleteRepoDialog> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText(
            '"${widget.repoName}"',
            flex: 0,
            style: context.theme.appTextStyle.bodyMedium
                .copyWith(fontWeight: FontWeight.w400),
          ),
          Text(
            S.current.messageConfirmRepositoryDeletion,
            style: context.theme.appTextStyle.bodyMedium,
          ),
          Fields.dialogActions(buttons: buildActions(context)),
        ],
      );

  List<Widget> buildActions(BuildContext context) => [
        NegativeButton(
          text: S.current.actionCancelCapital,
          onPressed: () async => await Navigator.of(context).maybePop(false),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        ),
        PositiveButton(
          text: S.current.actionDeleteCapital,
          onPressed: () async => await Navigator.of(context).maybePop(true),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
          isDangerButton: true,
        )
      ];
}
