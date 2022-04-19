import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../bloc/blocs.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
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
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
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
    if (actions == null) {
      actions = [TextButton(
        child: Text(S.current.actionCloseCapital),
        onPressed: () => Navigator.of(context).pop(false),
      )];
    }  

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

  static filePopupMenu(
    BuildContext context,
    Repository repository,
    Bloc bloc,
    Map<String, BaseItem> fileMenuOptions
  ) => PopupMenuButton(
    itemBuilder: (context) {
      return fileMenuOptions.entries.map((e) => 
        PopupMenuItem(
            child: Text(e.key),
            value: e,
        ) 
      ).toList();
    },
    onSelected: (value) {
      final data = (value as MapEntry<String, BaseItem>).value;
      switch (value.key) {
        case Strings.actionDeleteFile:
          _deleteFileWithConfirmation(context, repository, bloc, data.path);
          break;
      }
    }
  );

  static _deleteFileWithConfirmation(
    BuildContext context,
    repository,
    bloc,
    path
  ) => showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      final fileName = getBasename(path);
      final parent = getParentSection(path);

      return buildDeleteFileAlertDialog(repository, bloc, path, context, fileName, parent);
    },
  );

  static AlertDialog buildDeleteFileAlertDialog(
    repository,
    bloc,
    path,
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
            style: TextStyle(
              fontSize: Dimensions.fontAverage,
              fontWeight: FontWeight.bold
            ),
          ),
          Row(
            children: [
              Text(
                Strings.atSymbol,
                style: TextStyle(
                  fontSize: Dimensions.fontAverage,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                parent,
                style: TextStyle(
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
        child: Text(S.current.actionDelete),
        onPressed: () {
          bloc
          .add(
            DeleteFile(
              repository: repository,
              parentPath: parent,
              filePath: path
            )
          );
  
          Navigator.of(context).pop(fileName);

          showSnackBar(context, content: Text(S.current.messageFileDeleted(fileName)));
        },
      ),
      TextButton(
        child: Text(S.current.actionCancel),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
