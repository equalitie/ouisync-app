import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'utils.dart';

showSnackBar(BuildContext context, { required Widget content, SnackBarAction? action }) =>
  ScaffoldMessenger
  .of(context)
  .showSnackBar(
    SnackBar(
      content: content,
      action: action,
    ),  
  );

hideSnackBar(context) => 
  SnackBarAction(
    label: Strings.actionHide,
    onPressed: () => 
      ScaffoldMessenger.of(context).hideCurrentSnackBar()
  );

String getPathFromFileName(String path) => path.split(Strings.rootPath).last;

String extractParentFromPath(String path) {
  if (path.isEmpty) return Strings.rootPath;
  if (path == Strings.rootPath) return Strings.rootPath;

  final section = path.substring(0, path.lastIndexOf(Strings.rootPath)); 
  return section.isEmpty
  ? Strings.rootPath
  : section;
}

String removeParentFromPath(String path) {
  if (path == Strings.rootPath) {
    return path;
  }

  final index = path.lastIndexOf(Strings.rootPath);
  final section = path.substring(index + 1);
  
  return section;
}

String extractFileTypeFromName(String fileName) {
  if (!fileName.contains('.')) {
    return '';
  }

  if (fileName.lastIndexOf('.') > fileName.length - 2) {
    return '';
  }

  return fileName.substring(fileName.lastIndexOf('.') + 1);
}

getPathMap(String path) {
  final pathMap = new Map();

  var slashCount = path.split(Strings.rootPath).length - 1;
  var offset = 1;

  while (slashCount > 0) {
    var firstIndex = path.indexOf(Strings.rootPath, offset);
    var section = firstIndex > 0 
    ? path.substring(0, firstIndex) 
    : path;
    
    if (section.endsWith(Strings.rootPath)) {
      section = section.substring(0, section.length -1);
    }

    final parent = extractParentFromPath(section);
    pathMap[parent] = section;

    offset = firstIndex + 1;
    slashCount--;
  }

  return pathMap;
}

void showToast(String message, {Toast? length = Toast.LENGTH_SHORT}) => Fluttertoast
.showToast(
  msg: message,
  toastLength: length,
);

Future<void> copyStringToClipboard(String data) async {
  await Clipboard.setData(ClipboardData(text: data));
}

String? formNameValidator(String? value, { String error = Strings.messageErrorNameFormValidator }) {
  return value!.isEmpty ? error : null;
}