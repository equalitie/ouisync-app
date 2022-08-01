import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import '../models/models.dart' as model;
import 'utils.dart';

abstract class Dialogs {
  static Future<dynamic> executeFutureWithLoadingDialog(
    BuildContext context,
    Future<dynamic> f
  ) async {
    showLoadingDialog(context);

    var result = await f;
    _hideLoadingDialog(context);

    return result;
  }

  static void executeFunctionWithLoadingDialog(
    BuildContext context,
    Function f
  ) {
    showLoadingDialog(context);

    f.call();
    _hideLoadingDialog(context);
  }

  static showLoadingDialog(BuildContext context, {
    Widget? widget
  }) {
    final alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child:widget ?? Text(S.current.messageLoadingDefault)
            ),
        ],
      ),
    );

    return showDialog(
      context:context,
      barrierDismissible: false,
      builder:(BuildContext context){
        return alert; 
      },
    );
  }

  static _hideLoadingDialog(context) => 
    Navigator.pop(context);

  static Future<bool?> alertDialogWithActions({
    required BuildContext context,
    required String title,
    required List<Widget> body,
    required List<Widget> actions
  }) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _alertDialog(
        title,
        body,
        actions
      );
    }
  );

  static Future<bool?> simpleAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    List<Widget>? actions
  }) {
    actions ??= [TextButton(
        child: Text(S.current.actionCloseCapital),
        onPressed: () => Navigator.of(context).pop(false),
      )];  

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _alertDialog(
          title,
          [Text(message)],
          actions!
        );
      }
    );
  }

  static actionDialog(
    BuildContext context,
    String dialogTitle,
    Widget? actionBody
  ) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ActionsDialog(
        title: dialogTitle,
        body: actionBody,
      );
    }
  );

  static AlertDialog _alertDialog(
    String title,
    List<Widget> body,
    List<Widget> actions
  ) => AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(
      child: ListBody(children: body),
    ),
    actions: actions,
  );

  static AlertDialog buildDeleteFileAlertDialog(
    model.RepoState repository,
    DirectoryCubit cubit,
    String path,
    BuildContext context,
    String fileName,
    String parent
  ) => AlertDialog(
    title: Text(S.current.titleDeleteFile),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            fileName,
            style: const TextStyle(
              fontSize: Dimensions.fontAverage,
              fontWeight: FontWeight.bold
            ),
          ),
          Row(
            children: [
              const Text(
                Strings.atSymbol,
                style: TextStyle(
                  fontSize: Dimensions.fontAverage,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                parent,
                style: const TextStyle(
                  fontSize: Dimensions.fontAverage,
                  fontWeight: FontWeight.w700
                ),
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
        child: Text(S.current.actionDeleteCapital),
        onPressed: () {
          cubit.deleteFile(context, repository, path);
          Navigator.of(context).pop(fileName);
        },
      ),
      TextButton(
        child: Text(S.current.actionCancelCapital),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
