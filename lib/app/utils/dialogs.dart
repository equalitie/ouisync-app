import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../pages/pages.dart';
import 'utils.dart';

abstract class Dialogs {
  static Widget floatingActionsButtonMenu(
    Bloc bloc,
    BuildContext context,
    AnimationController controller,
    String reposBaseFolderPath, 
    String parentPath,
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
                Future<dynamic> dialog;
                switch (actionsDialog) {
                  case flagRepoActionsDialog:
                    dialog = repoActionsDialog(context, bloc, reposBaseFolderPath, actionName);
                    break;

                  case flagFolderActionsDialog:
                    dialog = folderActionsDialog(context, bloc, reposBaseFolderPath, parentPath, actionName);
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
            builder: (BuildContext context, Widget child) {
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

  static Future<dynamic> repoActionsDialog(BuildContext context, RepositoryBloc repositoryBloc, String reposBaseFolderPath, String action) {
    String dialogTitle;
    Widget actionBody;

    switch (action) {
      case actionNewRepo:
        dialogTitle = 'New Repository';
        actionBody = AddRepoPage(
          reposBaseFolderPath: reposBaseFolderPath
        );
        break;
    }

    return _actionDialog(
      context,
      dialogTitle,
      actionBody
    );
  }

  static Future<dynamic> folderActionsDialog(BuildContext context, DirectoryBloc directoryBloc, String reposBaseFolderPath, String parentPath, String action) {
    String dialogTitle;
    Widget actionBody;

    switch (action) {
      case actionNewFolder:
        dialogTitle = 'New Folder';
        actionBody = BlocProvider(
          create: (context) => directoryBloc,
          child: AddFolderPage(
            repoPath: reposBaseFolderPath,
            parentPath: parentPath,
          ),
        );
        break;
      
      case actionNewFile:
        dialogTitle = 'Add File';
        actionBody = BlocProvider(
          create: (context) => directoryBloc,
          child: AddFilePage(
            repoPath: reposBaseFolderPath,
            parentPath: parentPath,
          ),
        );
        break;
        
    }

    return _actionDialog(
      context,
      dialogTitle,
      actionBody
    );
  }

  static _actionDialog(BuildContext context, String dialogTitle, Widget actionBody) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return ActionsDialog(
        title: dialogTitle,
        body: actionBody,
      );
    }
  );

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