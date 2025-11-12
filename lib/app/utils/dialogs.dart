import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/stage.dart';

import '../../generated/l10n.dart';
import 'utils.dart' show AppThemeExtension, Fields, ThemeGetter;

class AlertDialogWithActions extends StatelessWidget {
  final String title;
  final List<Widget> body;
  final List<Widget> actions;

  const AlertDialogWithActions({
    required this.title,
    required this.body,
    required this.actions,
    super.key,
  });

  static Future<T?> show<T>(
    Stage stage, {
    required String title,
    required List<Widget> body,
    required List<Widget> actions,
  }) => stage.showDialog(
    builder: (context) =>
        AlertDialogWithActions(title: title, body: body, actions: actions),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Flex(
      direction: Axis.horizontal,
      children: [
        Fields.constrainedText(
          title,
          style: context.theme.appTextStyle.titleMedium,
          maxLines: 2,
        ),
      ],
    ),
    content: SingleChildScrollView(child: ListBody(children: body)),
    actions: actions,
  );
}

class SimpleAlertDialog extends StatelessWidget {
  final Stage stage;
  final String title;
  final String message;
  final List<Widget>? actions;

  const SimpleAlertDialog({
    required this.stage,
    required this.title,
    required this.message,
    this.actions,
    super.key,
  });

  static Future<T?> show<T>(
    Stage stage, {
    required String title,
    required String message,
    List<Widget>? actions,
  }) => stage.showDialog(
    builder: (context) => SimpleAlertDialog(
      stage: stage,
      title: title,
      message: message,
      actions: actions,
    ),
  );

  @override
  Widget build(BuildContext context) => AlertDialogWithActions(
    title: title,
    body: [Text(message)],
    actions:
        actions ??
        [
          TextButton(
            child: Text(S.current.actionCloseCapital),
            onPressed: () => stage.maybePop(false),
          ),
        ],
  );
}
