import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../pages/pages.dart';
import 'utils.dart';

abstract class Dialogs {
  static Future<dynamic> executeWithLoadingDialog(BuildContext context, Future<dynamic> f) async {
    _showLoadingDialog(context);

    var result = await f;
    _hideLoadingDialog(context);

    return result;
  }

  static _showLoadingDialog(BuildContext context) {
    final alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],
      ),
    );

    return showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert; 
      },
    );
  }

  static _hideLoadingDialog(context) => 
    Navigator.pop(context);

  static Widget floatingActionsButtonMenu(
    Bloc bloc,
    Session session,
    BuildContext context,
    AnimationController controller,
    String path,
    Map<String, IconData> actions,
    String actionsDialog,
    Color backgroundColor,
    Color foregroundColor,
  ) { 
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: new List.generate(actions.length, (int index) {
        String actionName = actions.keys.elementAt(index);

        Widget child = new Container(
          height: 70.0,
          width: 156.0,
          alignment: FractionalOffset.topCenter,
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: controller,
              curve: new Interval(
                0.0,
                1.0 - index / actions.length / 2.0,
                curve: Curves.easeOut
              ),
            ),
            child: new FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              label: Text(actionName),
              icon: Icon(actions[actionName]),
              onPressed: () async { 
                late Future<dynamic> dialog;
                switch (actionsDialog) {
                  case flagRepoActionsDialog:
                  /// Only one repository allowed for the MVP
                    // dialog = repoActionsDialog(context, bloc as RepositoryBloc, session, actionName);
                    break;

                  case flagFolderActionsDialog:
                    dialog = folderActionsDialog(context, bloc as DirectoryBloc, session, path, actionName);
                    break;

                  case flagReceiveShareActionsDialog:
                    dialog = receiveShareActionsDialog(context, bloc as DirectoryBloc, session, path, actionName);
                    break;

                  default:
                    return;
                }

                bool resultOk = await dialog;
                if (resultOk) {
                  controller.reset(); 
                }
              },
            ),
          ),
        );
        return child;
      }).toList()..add(
        new FloatingActionButton.extended(
          heroTag: null,
          label: Text('Actions'),
          icon: new AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              return new Transform(
                transform: new Matrix4.rotationZ(controller.value * 0.5 * math.pi),
                alignment: FractionalOffset.center,
                child: new Icon(controller.isDismissed ? Icons.pending : Icons.close),
              );
            },
          ),
          onPressed: () {
            controller.isDismissed
            ? controller.forward()
            : controller.reverse();
          },
        ),
      ),
    );
  }

  static Future<dynamic> repoActionsDialog(BuildContext context, RepositoryBloc repositoryBloc, Session session, String action) {
    String dialogTitle = '';
    Widget? actionBody;

    switch (action) {
      case actionNewRepo:
        dialogTitle = 'New Repository';
        actionBody = AddRepoPage(
          session: session,
          title: 'New Repository',
        );
        break;
    }

    return _actionDialog(
      context,
      dialogTitle,
      actionBody
    );
  }

  static Future<dynamic> folderActionsDialog(BuildContext context, DirectoryBloc directoryBloc, Session session, String path, String action) {
    String dialogTitle = '';
    Widget? actionBody;

    switch (action) {
      case actionNewFolder:
        dialogTitle = 'New Folder';
        actionBody = AddFolderPage(
          session: session,
          path: path,
          bloc: directoryBloc,
          title: 'New Folder',
        );
        break;
      
      case actionNewFile:
        dialogTitle = 'Add File';
        actionBody = AddFilePage(
          session: session,
          parentPath: path,
          bloc: directoryBloc,
          title: 'Add File',
        );
        break;

      case actionDeleteFolder:
        final parentPath = extractParentFromPath(path);

        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {

            return buildDeleteFolderAlertDialog(
              directoryBloc,
              session,
              parentPath,
              path,
              context,
            );
          },
        );
    }

    return _actionDialog(
      context,
      dialogTitle,
      actionBody
    );
  }

  static AlertDialog buildDeleteFolderAlertDialog(bloc, session, parentPath, path, BuildContext context) {
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
                session: session,
                parentPath: parentPath,
                path: path
              )
            );
    
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

  static Future<dynamic> receiveShareActionsDialog(BuildContext context, DirectoryBloc directoryBloc, Session session, String parentPath, String action) {
    String dialogTitle = '';
    Widget? actionBody;

    switch (action) {
      case actionNewFile:
        dialogTitle = 'Add File';
        actionBody = AddFilePage(
          session: session,
          parentPath: parentPath,
          bloc: directoryBloc,
          title: 'Add File',
        );
        break;
      case actionNewFolder:
        dialogTitle = 'New Folder';
        actionBody = AddFolderPage(
          session: session,
          path: parentPath,
          bloc: directoryBloc,
          title: 'New Folder',
        );
        break;
    }

    return _actionDialog(
      context,
      dialogTitle,
      actionBody
    );
  }

  static _actionDialog(BuildContext context, String dialogTitle, Widget? actionBody) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return ActionsDialog(
        title: dialogTitle,
        body: actionBody,
      );
    }
  );

  static filePopupMenu(BuildContext context, Session session, Bloc bloc, Map<String, BaseItem> fileMenuOptions) {
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
            _deleteFileWithConfirmation(context, bloc, session, data.path);
            break;
        }
      }
    );
  }

  static _deleteFileWithConfirmation(BuildContext context, bloc, session, path) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final fileName = getPathFromFileName(path);
        final parent = extractParentFromPath(path);

        return buildDeleteFileAlertDialog(bloc, session, path, context, fileName, parent);
      },
    );

  static AlertDialog buildDeleteFileAlertDialog(bloc, session, path, BuildContext context, String fileName, String parent) {
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
                session: session,
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

  static Future<void> showRequestStoragePermissionDialog(BuildContext context) async {
    Text title = Text('OuiSync - Storage permission needed');
    Text message = Text('Ouisync need access to the phone storage to operate properly.\n\nPlease accept the permissions request');
    
    await _permissionDialog(context, title, message);
  }

  static Future<void> showStoragePermissionNotGrantedDialog(BuildContext context) async {
    Text title = Text('OuiSync - Storage permission not granted');
    Text message = Text('Ouisync need access to the phone storage to operate properly.\n\nWithout this permission the app won\'t work.');
    
    await _permissionDialog(context, title, message);
  }

  static Future<void> _permissionDialog(BuildContext context, Widget title, Widget message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget> [
               message, 
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }
}