import 'package:equatable/equatable.dart';

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

class RequestContent extends DirectoryEvent {
  const RequestContent({
    required this.path,
    required this.recursive,
    required this.withProgressIndicator
  });

  final String path;
  final bool recursive;
  final bool withProgressIndicator;

  @override
  List<Object> get props => [
    path,
    recursive,
    withProgressIndicator
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