import 'dart:async';

import 'package:build_context_provider/build_context_provider.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import 'utils.dart';

abstract class Dialogs {
  static Future<T> executeWithLoadingDialog<T>(
      BuildContext context, Future<T> func()) {
    return executeFutureWithLoadingDialog(context, func());
  }

  static Future<T> executeFutureWithLoadingDialog<T>(
    BuildContext? context,
    Future<T> future,
  ) async {
    _showLoadingDialog(context);
    var result = await future;
    _hideLoadingDialog(context);

    return result;
  }

  static void _showLoadingDialog(BuildContext? context) => context != null
      ? _loadingDialog(context)
      : WidgetsBinding.instance
          .addPostFrameCallback((_) => BuildContextProvider()(_loadingDialog));

  static Future<void> _loadingDialog(BuildContext context) => showDialog(
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

  static _hideLoadingDialog(BuildContext? context) => context != null
      ? _popDialog(context)
      : BuildContextProvider()
          .call((globalContext) => _popDialog(globalContext));

  static void _popDialog(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).pop();

  static Future<bool?> alertDialogWithActions({
    required BuildContext context,
    required String title,
    required List<Widget> body,
    required List<Widget> actions,
  }) =>
      showDialog<bool?>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _alertDialog(context, title, body, actions);
          });

  static Future<bool?> simpleAlertDialog({
    required BuildContext context,
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
                    onPressed: () => Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pop(false),
                  ),
                ],
          );
        },
      );

  static actionDialog(
          BuildContext context, String dialogTitle, Widget? actionBody) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ActionsDialog(
              title: dialogTitle,
              body: actionBody,
            );
          });

  static AlertDialog _alertDialog(BuildContext context, String title,
          List<Widget> body, List<Widget> actions) =>
      AlertDialog(
          title: Flex(direction: Axis.horizontal, children: [
            Fields.constrainedText(title,
                style: context.theme.appTextStyle.titleMedium, maxLines: 2)
          ]),
          content: SingleChildScrollView(child: ListBody(children: body)),
          actions: actions);

  static Future<String?> deleteFileAlertDialog(RepoCubit repo, String path,
      BuildContext context, String fileName, String parent) async {
    final bodyStyle = context.theme.appTextStyle.bodyMedium
        .copyWith(fontWeight: FontWeight.bold);

    return showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.titleDeleteFile,
            body: ListBody(children: <Widget>[
              Text(fileName, style: bodyStyle),
              Row(children: [
                Text(Strings.atSymbol, style: bodyStyle),
                Text(parent, style: bodyStyle)
              ]),
              const SizedBox(height: 20.0),
              Text(S.current.messageConfirmFileDeletion),
              Fields.dialogActions(context, buttons: [
                NegativeButton(
                    text: S.current.actionCancel,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    buttonsAspectRatio:
                        Dimensions.aspectRatioModalDialogButton),
                PositiveButton(
                    text: S.current.actionDelete,
                    isDangerButton: true,
                    onPressed: () async {
                      await repo.deleteFile(path);
                      Navigator.of(context).pop(fileName);
                    },
                    buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
              ])
            ])));
  }

  static Future<bool?> deleteFolderAlertDialog(BuildContext context,
          RepoCubit repo, String path, String validationMessage) async =>
      showDialog<bool?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ActionsDialog(
          title: S.current.titleDeleteFolder,
          body: ListBody(
            children: <Widget>[
              Text(
                path,
                style: context.theme.appTextStyle.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Text(validationMessage),
              Fields.dialogActions(
                context,
                buttons: [
                  NegativeButton(
                    text: S.current.actionCancel,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(false),
                    buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
                  ),
                  PositiveButton(
                    text: S.current.actionDelete,
                    isDangerButton: true,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(true),
                    buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
