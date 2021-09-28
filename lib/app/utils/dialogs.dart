import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../models/models.dart';
import 'utils.dart';

abstract class Dialogs {
  static Future<dynamic> executeFutureWithLoadingDialog(BuildContext context, Future<dynamic> f) async {
    showLoadingDialog(context);

    var result = await f;
    _hideLoadingDialog(context);

    return result;
  }

  static void executeFunctionWithLoadingDialog(BuildContext context, Function f) {
    showLoadingDialog(context);

    f.call();
    _hideLoadingDialog(context);
  }

  static showLoadingDialog(BuildContext context, { Widget widget = const Text("Loading..." ) }) {
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

  static Future<dynamic> receiveShareActionsDialog(
    BuildContext context,
    DirectoryBloc directoryBloc,
    Function updateUI,
    String parentPath,
    String action
  ) async {
    String dialogTitle = '';
    Widget? actionBody;

    switch (action) {
      case actionNewFile:
        return await _addFileAction(parentPath, directoryBloc, updateUI);
        
      case actionNewFolder: {
          final formKey = GlobalKey<FormState>();

          dialogTitle = 'Create Folder';
          actionBody = FolderCreation(
            context: context,
            path: parentPath,
            formKey: formKey,
          );
        }
        break;
    }

    return actionDialog(
      context,
      dialogTitle,
      actionBody
    );
  }

  static _addFileAction(String path, DirectoryBloc directoryBloc, Function updateUI) async {
    final result = await FilePicker
    .platform
    .pickFiles(
      type: FileType.any,
      withReadStream: true
    );

    if(result != null) {
      final newFilePath = path == '/'
      ? '/${result.files.single.name}'
      : '$path/${result.files.single.name}';
      
      final fileByteStream = result.files.single.readStream!;
      
      directoryBloc
      .add(
        CreateFile(
          parentPath: path,
          newFilePath: newFilePath,
          fileByteStream: fileByteStream
        )
      );

      updateUI.call();
      
      return Future.value(true);
    }

    return Future.value(false);
  }

  static AlertDialog buildDeleteFolderAlertDialog(BuildContext context, bloc, updateUI, parentPath, path) {
    return AlertDialog(
      title: const Text('Delete folder'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              path,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text('Are you sure you want to delete this folder?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('DELETE'),
          onPressed: () {
            bloc
            .add(
              DeleteFolder(
                parentPath: parentPath,
                path: path
              )
            );

            updateUI.call();
    
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }

  static actionDialog(BuildContext context, String dialogTitle, Widget? actionBody) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ActionsDialog(
        title: dialogTitle,
        body: actionBody,
      );
    }
  );

  static filePopupMenu(BuildContext context, Bloc bloc, Map<String, BaseItem> fileMenuOptions) {
    return PopupMenuButton(
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
          case actionDeleteFile:
            _deleteFileWithConfirmation(context, bloc, data.path);
            break;
        }
      }
    );
  }

  static _deleteFileWithConfirmation(BuildContext context, bloc, path) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final fileName = getPathFromFileName(path);
        final parent = extractParentFromPath(path);

        return buildDeleteFileAlertDialog(bloc, path, context, fileName, parent);
      },
    );

  static AlertDialog buildDeleteFileAlertDialog(bloc, path, BuildContext context, String fileName, String parent) {
    return AlertDialog(
      title: const Text('Delete file'),
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
                  '@ ',
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
            const Text('Are you sure you want to delete this file?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('DELETE'),
          onPressed: () {
            bloc
            .add(
              DeleteFile(
                parentPath: parent,
                filePath: path
              )
            );
    
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}