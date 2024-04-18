import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/extensions.dart';

import '../../../../generated/l10n.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    required this.parentContext,
    required this.title,
    required this.body,
    this.actions,
  });

  final BuildContext parentContext;
  final Widget title;
  final List<Widget> body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Flex(
          direction: Axis.horizontal,
          children: [title],
        ),
        titleTextStyle:
            context.theme.appTextStyle.titleLarge.copyWith(color: Colors.black),
        content: SingleChildScrollView(child: ListBody(children: body)),
        actions: actions ??
            [
              TextButton(
                child: Text(S.current.actionCloseCapital),
                onPressed: () => Navigator.of(
                  parentContext,
                  rootNavigator: true,
                ).pop(false),
              )
            ],
      );
}
