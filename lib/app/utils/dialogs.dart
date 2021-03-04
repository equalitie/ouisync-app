import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class Dialogs {

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