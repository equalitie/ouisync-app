import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import 'utils.dart';

abstract class Dialogs {
  static Future<dynamic> executeFutureWithLoadingDialog(BuildContext context,
      {required Future<dynamic> f, String? text, Widget? widget}) async {
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

  static showLoadingDialog(BuildContext context,
      {String? text, Widget? widget}) {
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
            style: const TextStyle(
                color: Colors.white, fontSize: Dimensions.fontAverage),
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

  static Future<bool?> alertDialogWithActions(
          {required BuildContext context,
          required String title,
          required List<Widget> body,
          required List<Widget> actions}) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _alertDialog(title, body, actions);
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
          return _alertDialog(title, [Text(message)], actions!);
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

  static AlertDialog _alertDialog(
          String title, List<Widget> body, List<Widget> actions) =>
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(children: body),
        ),
        actions: actions,
      );

  static AlertDialog buildDeleteFileAlertDialog(RepoCubit repo, String path,
          BuildContext context, String fileName, String parent) =>
      AlertDialog(
        title: Text(S.current.titleDeleteFile),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                fileName,
                style: const TextStyle(
                    fontSize: Dimensions.fontAverage,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text(
                    Strings.atSymbol,
                    style: TextStyle(
                        fontSize: Dimensions.fontAverage,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    parent,
                    style: const TextStyle(
                        fontSize: Dimensions.fontAverage,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              Text(S.current.messageConfirmFileDeletion),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(S.current.actionCancelCapital),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          DangerButton(
            text: S.current.actionDeleteCapital,
            onPressed: () {
              repo.deleteFile(path);
              Navigator.of(context).pop(fileName);
            },
          ),
        ],
      );
}
