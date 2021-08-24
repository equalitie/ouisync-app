import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class CreateFolder extends DirectoryEvent {
  const CreateFolder({
    required this.session,
    required this.parentPath,
    required this.newFolderPath
  }) : 
  assert(newFolderPath != '');

  final Session session;
  final String parentPath;
  final String newFolderPath;

  @override
  List<Object> get props => [
    session,
    parentPath,
    newFolderPath,
  ];
}

class RequestContent extends DirectoryEvent {
  const RequestContent({
    required this.session,
    required this.path,
    required this.recursive,
    required this.withProgressIndicator
  });

  final Session session;
  final String path;
  final bool recursive;
  final bool withProgressIndicator;

  @override
  List<Object> get props => [
    session,
    path,
    recursive,
    withProgressIndicator
  ];

}

class CreateFile extends DirectoryEvent {
  const CreateFile({
    required this.session,
    required this.parentPath,
    required this.newFilePath,
    required this.fileByteStream
  }) :
  assert (newFilePath != '');

  final Session session;
  final String parentPath;
  final String newFilePath;
  final Stream<List<int>> fileByteStream;

  @override
  List<Object> get props => [
    session,
    parentPath,
    newFilePath,
    fileByteStream
  ];
  
}

class ReadFile extends DirectoryEvent {
  const ReadFile({
    required this.session,
    required this.parentPath,
    required this.filePath,
    required this.action,
  }) :
  assert (filePath != ''),
  assert (action != '');

  final Session session;
  final String parentPath;
  final String filePath;
  final String action;

  @override
  List<Object> get props => [
    session,
    parentPath,
    filePath,
    action
  ];

}

class DeleteFile extends DirectoryEvent {
  const DeleteFile({
    required this.session,
    required this.parentPath,
    required this.filePath,
  }) :
  assert (filePath != '');

  final Session session;
  final String parentPath;
  final String filePath;

  @override
  List<Object> get props => [
    session,
    parentPath,
    filePath,
  ];

}

class DeleteFolder extends DirectoryEvent {
  const DeleteFolder({
    required this.session,
    required this.parentPath,
    required this.path,
  }) :
  assert (path != '');

  final Session session;
  final String parentPath;
  final String path;

  @override
  List<Object> get props => [
    session,
    path,
  ];

}