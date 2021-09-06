import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../bloc/blocs.dart';
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
  if (path.isEmpty) return slash;
  if (path == slash) return slash;

  final section = path.substring(0, path.lastIndexOf('/')); 
  return section.isEmpty
  ? slash
  : section;
}

String removeParentFromPath(String path) {
  if (path == slash) {
    return path;
  }

  final index = path.lastIndexOf(slash);
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

loadRoot(bloc) => 
bloc.add(
  NavigateTo(
    type: Navigation.content,
    origin: slash,
    destination: slash,
    withProgress: true
  )
);

getPathMap(String path) {
  final pathMap = new Map();

  var slashCount = path.split(slash).length - 1;
  var offset = 1;

  while (slashCount > 0) {
    var firstIndex = path.indexOf(slash, offset);
    var section = firstIndex > 0 
    ? path.substring(0, firstIndex) 
    : path;
    
    if (section.endsWith(slash)) {
      section = section.substring(0, section.length -1);
    }

    final parent = extractParentFromPath(section);
    pathMap[parent] = section;

    offset = firstIndex + 1;
    slashCount--;
  }

  return pathMap;
}