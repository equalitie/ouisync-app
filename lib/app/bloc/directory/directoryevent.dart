import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class CreateFolder extends DirectoryEvent {
  const CreateFolder({
    @required this.repository,
    @required this.parentPath,
    @required this.newFolderPath
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

class RequestContent extends DirectoryEvent {
  const RequestContent({
    @required this.repository,
    @required this.path,
    @required this.recursive
  });

  final Repository repository;
  final String path;
  final bool recursive;

  @override
  List<Object> get props => [
    repository,
    path,
    recursive
  ];

}

class CreateFile extends DirectoryEvent {
  const CreateFile({
    @required this.repository,
    @required this.parentPath,
    @required this.newFilePath,
    @required this.fileByteStream
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
    @required this.repository,
    @required this.parentPath,
    @required this.filePath
  }) :
  assert (filePath != '');

  final Repository repository;
  final String parentPath;
  final String filePath;

  @override
  List<Object> get props => [
    repository,
    parentPath,
    filePath
  ];

}