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
  });

  final Repository repository;
  final String path;
  final bool recursive;
  final bool withProgress;

  @override
  List<Object> get props => [
    repository,
    path,
    recursive,
    withProgress,
  ];

}

class DeleteFolder extends DirectoryEvent {
  const DeleteFolder({
    required this.repository,
    required this.parentPath,
    required this.path,
    this.recursive = false
  }) :
  assert (path != '');

  final Repository repository;
  final String parentPath;
  final String path;
  final bool recursive;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    path,
    recursive
  ];

}

class NavigateTo extends DirectoryEvent {
  const NavigateTo({
    required this.repository,
    this.previousAccessMode,
    required this.type,
    required this.origin,
    required this.destination,
    required this.withProgress
  }) :
  assert (origin != ''),
  assert (destination != '');

  final Repository repository;
  final AccessMode? previousAccessMode;
  final Navigation type;
  final String origin;
  final String destination;
  final bool withProgress;

  @override
  List<Object?> get props => [
    repository,
    previousAccessMode,
    type,
    origin,
    destination,
    withProgress
  ];
} 

class SaveFile extends DirectoryEvent {
  const SaveFile({
    required this.repository,
    required this.newFilePath,
    required this.fileName,
    required this.length,
    required this.fileByteStream
  });

  final Repository repository;
  final String newFilePath;
  final String fileName;
  final int length;
  final Stream<List<int>> fileByteStream;

  @override
  List<Object?> get props => [
    repository,
    newFilePath,
    fileName,
    length,
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
    required this.newDestinationPath
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

  @override
  List<Object> get props => [
    repository,
    origin,
    destination,
    entryPath,
    newDestinationPath
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
