import 'dart:async';

import 'package:build_context_provider/build_context_provider.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoCubit;
import '../models/models.dart' show FileSystemEntry, FileEntry;
import '../utils/repo_path.dart' as repo_path;
import '../widgets/widgets.dart' show NegativeButton, PositiveButton;
import 'utils.dart'
    show AppThemeExtension, Dimensions, Fields, Strings, ThemeGetter;

abstract class Dialogs {
  static int _loadingInvocations = 0;

  static Future<T> executeWithLoadingDialog<T>(
      BuildContext? context, Future<T> Function() func) {
    return executeFutureWithLoadingDialog(context, func());
  }

  static Future<T> executeFutureWithLoadingDialog<T>(
    BuildContext? context,
    Future<T> future,
  ) async {
    if (_loadingInvocations == 0) {
      _showLoadingDialog(context);
    }

    _loadingInvocations += 1;

    try {
      return await future;
    } finally {
      _loadingInvocations -= 1;
      if (_loadingInvocations == 0) {
        _hideLoadingDialog(context);
      }
    }
  }

  static void _showLoadingDialog(BuildContext? context) => context != null
      ? unawaited(_loadingDialog(context))
      : WidgetsBinding.instance.addPostFrameCallback(
          (_) => BuildContextProvider()((c) => unawaited(_loadingDialog(c))));

  static Future<void> _loadingDialog(BuildContext context) async => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PopScope(
            canPop: false,
            child: Center(
              child: const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ));

  static void _hideLoadingDialog(BuildContext? context) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => context != null
          ? _popDialog(context)
          : BuildContextProvider().call((c) => _popDialog(c)));

  static void _popDialog(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).pop();

  static Future<bool?> alertDialogWithActions<bool>(
    BuildContext context, {
    required String title,
    required List<Widget> body,
    required List<Widget> actions,
  }) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _alertDialog(
          context,
          title,
          body,
          actions,
        ),
      );

  static Future<bool?> simpleAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    List<Widget>? actions,
  }) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _alertDialog(
            context,
            title,
            [Text(message)],
            actions ??
                [
                  TextButton(
                    child: Text(S.current.actionCloseCapital),
                    onPressed: () async => await Navigator.of(
                      context,
                      rootNavigator: true,
                    ).maybePop(false),
                  ),
                ],
          );
        },
      );

  static AlertDialog _alertDialog(
    BuildContext context,
    String title,
    List<Widget> body,
    List<Widget> actions,
  ) =>
      AlertDialog(
        title: Flex(
          direction: Axis.horizontal,
          children: [
            Fields.constrainedText(
              title,
              style: context.theme.appTextStyle.titleMedium,
              maxLines: 2,
            )
          ],
        ),
        content: SingleChildScrollView(child: ListBody(children: body)),
        actions: actions,
      );

  static Future<bool> deleteEntry(
    BuildContext context, {
    required RepoCubit repoCubit,
    required FileSystemEntry entry,
    bool? isDirEmpty,
  }) async {
    final bodyStyle = context.theme.appTextStyle.bodyMedium
        .copyWith(fontWeight: FontWeight.bold);

    final validationMessage = entry is FileEntry
        ? S.current.messageConfirmFileDeletion
        : (isDirEmpty ?? false)
            ? S.current.messageConfirmFolderDeletion
            : S.current.messageConfirmNotEmptyFolderDeletion;

    final fileParentPath = entry is FileEntry
        ? repo_path.dirname(
            entry.path,
          )
        : '';

    final title = entry is FileEntry
        ? S.current.titleDeleteFile
        : S.current.titleDeleteFolder;

    final body = entry is FileEntry
        ? [
            Text(entry.name, style: bodyStyle),
            Text('${Strings.atSymbol} $fileParentPath', style: bodyStyle),
            Dimensions.spacingVerticalDouble,
            Text(validationMessage),
          ]
        : [
            Text(entry.path, style: bodyStyle),
            Dimensions.spacingVerticalDouble,
            Text(validationMessage),
          ];

    final actions = [
      Row(children: [
        NegativeButton(
          text: S.current.actionCancel,
          onPressed: () async => await Navigator.of(
            context,
            rootNavigator: true,
          ).maybePop(false),
        ),
        PositiveButton(
          text: S.current.actionDelete,
          isDangerButton: true,
          onPressed: () async => await Navigator.of(
            context,
            rootNavigator: true,
          ).maybePop(true),
        ),
      ])
    ];

    final result = await alertDialogWithActions<bool>(
          context,
          title: title,
          body: body,
          actions: actions,
        ) ??
        false;

    return result;
  }
}
