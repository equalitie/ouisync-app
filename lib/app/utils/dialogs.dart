import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../bloc/blocs.dart';
import '../custom_widgets/custom_widgets.dart';
import '../models/models.dart';
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
    Widget widget = const Text(Strings.mesageLoading) 
  }) {
    final alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
            child:widget
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
  }) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _alertDialog(
        title,
        [Text(message)],
        [TextButton(
          child: const Text(Strings.actionClose),
          onPressed: () => Navigator.of(context).pop(false),
        )]
      );
    }
  );

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
      final fileName = getPathFromFileName(path);
      final parent = extractParentFromPath(path);

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
    title: const Text(Strings.titleDeleteFile),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            fileName,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold
            ),
          ),
          Row(
            children: [
              Text(
                Strings.atSymbol,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                parent,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700
                ),
              )
            ],
          ),
          const SizedBox(
            height: 30.0,
          ),
          const Text(Strings.messageConfirmFileDeletion),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: const Text(Strings.actionDelete),
        onPressed: () {
          bloc
          .add(
            DeleteFile(
              repository: repository,
              parentPath: parent,
              filePath: path
            )
          );
  
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: const Text(Strings.actionCancel),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}