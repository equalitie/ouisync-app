import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import 'utils.dart';

String getPathFromFileName(String path) => path.split('/').last;

String extractParentFromPath(String path) {
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

