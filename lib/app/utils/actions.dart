import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    label: 'HIDE',
    onPressed: () => 
      ScaffoldMessenger.of(context).hideCurrentSnackBar()
  );

String getPathFromFileName(String path) => path.split('/').last;

String extractParentFromPath(String path) {
  if (path.isEmpty) return Strings.slash;
  if (path == Strings.slash) return Strings.slash;

  final section = path.substring(0, path.lastIndexOf('/')); 
  return section.isEmpty
  ? Strings.slash
  : section;
}

String removeParentFromPath(String path) {
  if (path == Strings.slash) {
    return path;
  }

  final index = path.lastIndexOf(Strings.slash);
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

  var slashCount = path.split(Strings.slash).length - 1;
  var offset = 1;

  while (slashCount > 0) {
    var firstIndex = path.indexOf(Strings.slash, offset);
    var section = firstIndex > 0 
    ? path.substring(0, firstIndex) 
    : path;
    
    if (section.endsWith(Strings.slash)) {
      section = section.substring(0, section.length -1);
    }

    final parent = extractParentFromPath(section);
    pathMap[parent] = section;

    offset = firstIndex + 1;
    slashCount--;
  }

  return pathMap;
}