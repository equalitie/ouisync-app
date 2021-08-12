import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/models/models.dart';

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

loadRoot(bloc) => 
bloc.add(
  NavigateTo(
    Navigation.folder,
    slash,
    slash,
    FolderItem(creationDate: DateTime.now(), lastModificationDate: DateTime.now(), items: <BaseItem>[])
  )
);

sectionWidget(text) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(1.0),
      color: text == slash
      ? Colors.black
      : Colors.amber[500],
      shape: BoxShape.rectangle,
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(10.0, 1.0, 15.0, 2.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      )
    )
  );

  slashWidget() => Text(
    slash,
    style: TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  );

  buildRouteSection(Bloc bloc, String parentPath, String destinationPath, data) {
    final text = destinationPath == slash
    ? destinationPath
    : removeParentFromPath(destinationPath).replaceAll(slash, '').trim();

    return GestureDetector(
      onTap: () => navigateToSection(bloc, parentPath, destinationPath, data),
      child: sectionWidget(text),
    );
  }

  buildRoute(route) => Padding(
    padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 1.0),
    child: Row(
      children: route,
    ),
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

  navigateToSection(bloc, parent, destination, data) => bloc
    .add(
      NavigateTo(
        Navigation.folder,
        parent,
        destination,
        data
      )
    );