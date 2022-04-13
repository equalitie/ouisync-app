import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import '../../models/named_repo.dart';

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

  final NamedRepo repository;
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
  });

  final NamedRepo repository;
  final String path;

  @override
  List<Object> get props => [
    repository,
    path,
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

  final NamedRepo repository;
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
    required this.origin,
    required this.destination,
    required this.withProgress
  }) :
  assert (origin != ''),
  assert (destination != '');

  final NamedRepo repository;
  final AccessMode? previousAccessMode;
  final String origin;
  final String destination;
  final bool withProgress;

  @override
  List<Object?> get props => [
    repository,
    previousAccessMode,
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

  final NamedRepo repository;
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

class CancelSaveFile extends DirectoryEvent {
  const CancelSaveFile({
    required this.filePath
  });

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class RenameEntry extends DirectoryEvent {
  const RenameEntry({
    required this.repository,
    required this.path,
    required this.entryPath,
    required this.newEntryPath,
  }) :
  assert (path != ''),
  assert (entryPath != ''),
  assert (newEntryPath != '');

  final NamedRepo repository;
  final String path;
  final String entryPath;
  final String newEntryPath;

  @override
  List<Object?> get props => [
    repository,
    path,
    entryPath,
    newEntryPath
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

  final NamedRepo repository;
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

  final NamedRepo repository;
  final String parentPath;
  final String filePath;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    filePath,
  ];

}
