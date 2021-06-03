import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import 'utils.dart';

void push(BuildContext context, {Widget? widget, bool replace = false}) {
  if (replace) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget! )
    ); 
  }
  else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget! )
    );
  }
}

Future<PermissionStatus> checkRequiredPermissions (BuildContext context) async {
  PermissionStatus _permissionStatus = await Permission.storage.status;
  
  if (negativePermissionStatus.contains(_permissionStatus)) {
    _permissionStatus = await requestPermissions(context);
  }

  return _permissionStatus;
}

Future<PermissionStatus> requestPermissions(BuildContext context) async {
  await Dialogs.showRequestStoragePermissionDialog(context);

  return Permission.storage.request();
}

Future<void> printAppFolderContents(String path) async {
  final Directory _directory = Directory(path);
  
  print('${_directory.path} contents:\n\n');
  
  var contents = _directory.listSync();
  for (var item in contents) {
    print(item); 
  }
}

String removePathFromFileName(String path) => path.split('/').last;

String removeFileNameFromPath(String path) => path.substring(0, path.lastIndexOf('/')); 

dynamic extractNativeAttribute(List<String> attributesList, String attribute) => 
  attributesList.singleWhere((element) => element.startsWith('$attribute:')).split(':')[1];

String extractFileTypeFromName(String fileName) {
  if (!fileName.contains('.')) {
    return '';
  }

  if (fileName.lastIndexOf('.') > fileName.length - 2) {
    return '';
  }

  return fileName.substring(fileName.lastIndexOf('.') + 1);
}

