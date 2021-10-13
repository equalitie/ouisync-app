import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'directory_state.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class CreateFolder extends DirectoryEvent {
  const CreateFolder({
    required this.repository,
    required this.parentPath,
    required this.newFolderPath
  }) : 
  assert(newFolderPath != '');

  final Repository repository;
  final String parentPath;
  final String newFolderPath;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    newFolderPath,
  ];
}

class GetContent extends DirectoryEvent {
  const GetContent({
    required this.repository,
    required this.path,
    required this.recursive,
    required this.withProgress,
    this.isSyncing = false
  });

  final Repository repository;
  final String path;
  final bool recursive;
  final bool withProgress;
  final bool isSyncing;

  @override
  List<Object> get props => [
    repository,
    path,
    recursive,
    withProgress,
    isSyncing
  ];

}

class DeleteFolder extends DirectoryEvent {
  const DeleteFolder({
    required this.repository,
    required this.parentPath,
    required this.path,
  }) :
  assert (path != '');

  final Repository repository;
  final String parentPath;
  final String path;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    path,
  ];

}

class NavigateTo extends DirectoryEvent {
  const NavigateTo({
    required this.repository,
    required this.type,
    required this.origin,
    required this.destination,
    required this.withProgress
  }) :
  assert (origin != ''),
  assert (destination != '');

  final Repository repository;
  final Navigation type;
  final String origin;
  final String destination;
  final bool withProgress;

  @override
  List<Object?> get props => [
    repository,
    type,
    origin,
    destination,
    withProgress
  ];
} 

class CreateFile extends DirectoryEvent {
  const CreateFile({
    required this.repository,
    required this.parentPath,
    required this.newFilePath,
    required this.fileByteStream
  }) :
  assert (newFilePath != '');

  final Repository repository;
  final String parentPath;
  final String newFilePath;
  final Stream<List<int>> fileByteStream;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    newFilePath,
    fileByteStream
  ];
  
}

class ReadFile extends DirectoryEvent {
  const ReadFile({
    required this.repository,
    required this.parentPath,
    required this.filePath,
    required this.action,
  }) :
  assert (filePath != ''),
  assert (action != '');

  final Repository repository;
  final String parentPath;
  final String filePath;
  final String action;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    filePath,
    action
  ];

}

class MoveEntry extends DirectoryEvent {
  const MoveEntry({
    required this.repository,
    required this.origin,
    required this.destination,
    required this.entryPath,
    required this.newDestinationPath,
    this.navigate = false
  }) :
  assert (origin != ''),
  assert (destination != ''),
  assert (entryPath != ''),
  assert (newDestinationPath != '');

  final Repository repository;
  final String origin;
  final String destination;
  final String entryPath;
  final String newDestinationPath;
  final bool navigate;

  @override
  List<Object> get props => [
    repository,
    origin,
    destination,
    entryPath,
    newDestinationPath,
    navigate
  ];

}

class DeleteFile extends DirectoryEvent {
  const DeleteFile({
    required this.repository,
    required this.parentPath,
    required this.filePath,
  }) :
  assert (filePath != '');

  final Repository repository;
  final String parentPath;
  final String filePath;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    filePath,
  ];

}