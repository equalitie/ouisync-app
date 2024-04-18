import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/dialogs/alert/alert.dart';
import '../widgets/widgets.dart';
import 'utils.dart';

abstract class Dialogs {
  static Future<T> executeFutureWithLoadingDialog<T>(
    BuildContext context,
    Future<T> future,
  ) async {
    _showLoadingDialog(context);
    var result = await future;
    _hideLoadingDialog(context);

    return result;
  }

  static _showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: const CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  static _hideLoadingDialog(context) =>
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

  static Future<bool?> showSimpleAlertDialog({
    required BuildContext context,
    required Widget title,
    required Widget message,
    List<Widget>? actions,
  }) {
    actions ??= [
      CustomAlertAction(
        parentContext: context,
        text: S.current.actionCloseCapital,
      )
    ];

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          parentContext: context,
          title: title,
          body: [message],
          actions: actions,
        );
      },
    );
  }

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
