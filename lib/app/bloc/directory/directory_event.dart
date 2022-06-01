import 'package:equatable/equatable.dart';

import '../../models/repo_state.dart';

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
    required this.path,
    this.recursive = false
  }) :
  assert (path != '');

  final RepoState repository;
  final String path;
  final bool recursive;

  @override
  List<Object> get props => [
    repository,
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
  List<Object?> get props => [ filePath ];
}

class DownloadFile extends DirectoryEvent {
  const DownloadFile({
    required this.repository,
    required this.originFilePath,
    required this.destinationPath
  });

  final RepoState repository;
  final String originFilePath;
  final String destinationPath;

  @override
  List<Object?> get props => [
    repository,
    originFilePath,
    destinationPath
  ];
}

class CancelDownloadFile extends DirectoryEvent {
  const CancelDownloadFile({
    required this.repository,
    required this.filePath
  });

  final RepoState repository;
  final String filePath;

  @override
  List<Object?> get props => [ repository, filePath ];
}

class MoveEntry extends DirectoryEvent {
  const MoveEntry({
    required this.repository,
    required this.source,
    required this.destination
  }) :
  assert (source != ''),
  assert (destination != '');

  final RepoState repository;
  final String source;
  final String destination;

  @override
  List<Object> get props => [
    repository,
    source,
    destination
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
