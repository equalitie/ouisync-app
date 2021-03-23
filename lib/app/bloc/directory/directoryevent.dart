import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class FolderCreate extends DirectoryEvent {
  const FolderCreate({
    @required this.repoPath,
    @required this.parentPath,
    @required this.newFolderRelativePath
  }) : 
  assert(repoPath != null),
  assert(repoPath != ''),
  assert(parentPath != null),
  assert(newFolderRelativePath != null),
  assert(newFolderRelativePath != '');

  final String repoPath;
  final String parentPath;
  final String newFolderRelativePath;

  @override
  List<Object> get props => [
    repoPath,
    parentPath,
    newFolderRelativePath,
  ];
}

class ContentRequest extends DirectoryEvent {
  const ContentRequest({
    @required this.repoPath,
    @required this.folderRelativePath,
  }) : 
  assert(repoPath != null),
  assert(folderRelativePath != null);

  final String repoPath;
  final String folderRelativePath;

  @override
  List<Object> get props => [
    repoPath,
    folderRelativePath,
  ];

}