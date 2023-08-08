import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import 'utils.dart';

abstract class Dialogs {
  static Future<T> executeFutureWithLoadingDialog<T>(
    BuildContext context, {
    required Future<T> f,
    String? text,
    Widget? widget,
  }) async {
    showLoadingDialog(context, text: text, widget: widget);

    var result = await f;
    _hideLoadingDialog(context);

    return result;
  }

  static void executeFunctionWithLoadingDialog(
      BuildContext context, Function f) {
    showLoadingDialog(context);

    f.call();
    _hideLoadingDialog(context);
  }

  static showLoadingDialog(
    BuildContext context, {
    String? text,
    Widget? widget,
  }) {
    final defaultIndicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        if (text?.isNotEmpty ?? false) Dimensions.spacingVertical,
        if (text?.isNotEmpty ?? false)
          Text(
            text!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: widget != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget,
                  ],
                )
              : defaultIndicator,
        );
      },
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

  static Future<bool?> simpleAlertDialog(
      {required BuildContext context,
      required String title,
      required String message,
      List<Widget>? actions}) {
    actions ??= [
      TextButton(
        child: Text(S.current.actionCloseCapital),
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
      )
    ];

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _alertDialog(context, title, [Text(message)], actions!);
        });
  }

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
      List<Widget> body, List<Widget> actions) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return AlertDialog(
      title: Text(title, style: titleStyle),
      content: SingleChildScrollView(
        child: ListBody(children: body),
      ),
      actions: actions,
    );
  }

  static Future<String?> deleteFileAlertDialog(RepoCubit repo, String path,
      BuildContext context, String fileName, String parent) async {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    return showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.titleDeleteFile,
            body: ListBody(children: <Widget>[
              Text(fileName,
                  style: bodyStyle?.copyWith(fontWeight: FontWeight.bold)),
              Row(children: [
                Text(Strings.atSymbol,
                    style: bodyStyle?.copyWith(fontWeight: FontWeight.bold)),
                Text(parent)
              ]),
              const SizedBox(height: 30.0),
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

  static Future<String?> deleteFolderAlertDialog(
      BuildContext context, RepoCubit repo, String path, bool recursive) async {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    return showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.titleDeleteFolder,
            body: ListBody(children: <Widget>[
              Text(path,
                  style: bodyStyle?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 30.0),
              Text(S.current.messageConfirmFolderDeletion),
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
                      await repo.deleteFolder(path, recursive);
                      Navigator.of(context).pop(path);
                    },
                    buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
              ])
            ])));
  }
}
