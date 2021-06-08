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
    required this.recursive
  });

  final Session session;
  final String path;
  final bool recursive;

  @override
  List<Object> get props => [
    session,
    path,
    recursive
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