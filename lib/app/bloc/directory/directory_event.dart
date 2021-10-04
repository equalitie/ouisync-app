import 'package:equatable/equatable.dart';

import 'directory_state.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class CreateFolder extends DirectoryEvent {
  const CreateFolder({
    required this.parentPath,
    required this.newFolderPath
  }) : 
  assert(newFolderPath != '');

  final String parentPath;
  final String newFolderPath;

  @override
  List<Object> get props => [
    parentPath,
    newFolderPath,
  ];
}

class GetContent extends DirectoryEvent {
  const GetContent({
    required this.path,
    required this.recursive,
    required this.withProgress,
    this.isSyncing = false
  });

  final String path;
  final bool recursive;
  final bool withProgress;
  final bool isSyncing;

  @override
  List<Object> get props => [
    path,
    recursive,
    withProgress,
    isSyncing
  ];

}

class DeleteFolder extends DirectoryEvent {
  const DeleteFolder({
    required this.parentPath,
    required this.path,
  }) :
  assert (path != '');

  final String parentPath;
  final String path;

  @override
  List<Object> get props => [
    parentPath,
    path,
  ];

}

class NavigateTo extends DirectoryEvent {
  const NavigateTo({
    required this.type,
    required this.origin,
    required this.destination,
    required this.withProgress
  }) :
  assert (origin != ''),
  assert (destination != '');

  final Navigation type;
  final String origin;
  final String destination;
  final bool withProgress;

  @override
  List<Object?> get props => [
    type,
    origin,
    destination,
    withProgress
  ];
} 

class CreateFile extends DirectoryEvent {
  const CreateFile({
    required this.parentPath,
    required this.newFilePath,
    required this.fileByteStream
  }) :
  assert (newFilePath != '');

  final String parentPath;
  final String newFilePath;
  final Stream<List<int>> fileByteStream;

  @override
  List<Object> get props => [
    parentPath,
    newFilePath,
    fileByteStream
  ];
  
}

class ReadFile extends DirectoryEvent {
  const ReadFile({
    required this.parentPath,
    required this.filePath,
    required this.action,
  }) :
  assert (filePath != ''),
  assert (action != '');

  final String parentPath;
  final String filePath;
  final String action;

  @override
  List<Object> get props => [
    parentPath,
    filePath,
    action
  ];

}

class MoveFile extends DirectoryEvent {
  const MoveFile({
    required this.origin,
    required this.destination,
    required this.filePath,
    required this.newFilePath,
    this.navigate = false
  }) :
  assert (origin != ''),
  assert (destination != ''),
  assert (filePath != ''),
  assert (newFilePath != '');

  final String origin;
  final String destination;
  final String filePath;
  final String newFilePath;
  final bool navigate;

  @override
  List<Object> get props => [
    origin,
    destination,
    filePath,
    newFilePath,
    navigate
  ];

}

class DeleteFile extends DirectoryEvent {
  const DeleteFile({
    required this.parentPath,
    required this.filePath,
  }) :
  assert (filePath != '');

  final String parentPath;
  final String filePath;

  @override
  List<Object> get props => [
    parentPath,
    filePath,
  ];

}