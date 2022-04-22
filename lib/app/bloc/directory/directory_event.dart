import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import '../../models/repo_state.dart';
import '../../models/folder_state.dart';

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

  final RepoState repository;
  final String parentPath;
  final String newFolderPath;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    newFolderPath,
  ];
}

class NavigateTo extends DirectoryEvent {
  const NavigateTo(this.repository, this.destination);

  final RepoState repository;
  final String destination;

  @override
  List<Object> get props => [
    repository,
    destination,
  ];
}

class GetContent extends DirectoryEvent {
  const GetContent({required this.repository});

  final RepoState repository;

  @override
  List<Object> get props => [
    repository,
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

  final RepoState repository;
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

class SaveFile extends DirectoryEvent {
  const SaveFile({
    required this.repository,
    required this.newFilePath,
    required this.fileName,
    required this.length,
    required this.fileByteStream
  });

  final RepoState repository;
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

  final RepoState repository;
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

  final RepoState repository;
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

  final RepoState repository;
  final String parentPath;
  final String filePath;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    filePath,
  ];

}
