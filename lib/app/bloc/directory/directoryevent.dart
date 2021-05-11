import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class CreateFolder extends DirectoryEvent {
  const CreateFolder({
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

class RequestContent extends DirectoryEvent {
  const RequestContent({
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

class CreateFile extends DirectoryEvent {
  const CreateFile({
    @required this.repoPath,
    @required this.parentPath,
    @required this.newFileRelativePath,
    @required this.fileStream
  }) :
  assert (repoPath != null),
  assert (repoPath != ''),
  assert (parentPath != null),
  assert (newFileRelativePath != null),
  assert (newFileRelativePath != ''),
  assert (fileStream != null);

  final String repoPath;
  final String newFileRelativePath;
  final String parentPath;
  final Stream<List<int>> fileStream;

  @override
  List<Object> get props => [
    repoPath,
    parentPath,
    newFileRelativePath,
    fileStream
  ];
  
}

class ReadFile extends DirectoryEvent {
  const ReadFile({
    @required this.repoPath,
    @required this.parentPath,
    @required this.fileRelativePath,
    @required this.totalBytes
  }) :
  assert (repoPath != null),
  assert (repoPath != ''),
  assert (parentPath != null),
  assert (fileRelativePath != null),
  assert (fileRelativePath != ''),
  assert (totalBytes != null),
  assert (totalBytes > 0);

  final String repoPath;
  final String parentPath;
  final String fileRelativePath;
  final double totalBytes;

  @override
  List<Object> get props => [
    repoPath,
    parentPath,
    fileRelativePath,
    totalBytes
  ];

}