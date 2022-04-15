import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';

abstract class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object?> get props => [];
}

class DirectoryInitial extends DirectoryState {}

class CreateFileDone extends DirectoryState {
  const CreateFileDone({
    required this.file,
    required this.path,
    required this.fileName,
    required this.extension
  });

  final File file;
  final String path;
  final String fileName;
  final String extension;

  @override
  List<Object> get props => [
    file,
    path,
    fileName,
    extension
  ];
}

class CreateFileFailure extends DirectoryState {
  const CreateFileFailure({
    required this.path,
  });

  final String path;

  @override
  List<Object> get props => [
    path,
  ];
}

class WriteToFileInProgress extends DirectoryState {
  const WriteToFileInProgress({
    required this.path,
    required this.fileName,
    required this.length,
    required this.progress
  });

  final String path;
  final String fileName;
  final int length;
  final int progress;

  @override
  List<Object> get props => [
    path,
    fileName,
    length,
    progress
  ];
}

class WriteToFileDone extends DirectoryState {
  const WriteToFileDone({
    required this.path,
    required this.fileName,
    required this.length
  });

  final String path;
  final String fileName;
  final int length;

  @override
  List<Object> get props => [
    path,
    fileName,
    length
  ];
}

class WriteToFileCanceled extends DirectoryState {
  const WriteToFileCanceled({
    required this.path,
    required this.fileName
  });

  final String path;
  final String fileName;

  @override
  List<Object> get props => [
    path,
    fileName,
  ];
}

class WriteToFileFailure extends DirectoryState {
  const WriteToFileFailure({
    required this.path,
    required this.fileName,
    required this.length,
    required this.error
  });

  final String path;
  final String error;
  final String fileName;
  final int length;

  @override
  List<Object> get props => [
    path,
    fileName,
    length,
    error
  ];
}

class DirectoryLoadInProgress extends DirectoryState {
  const DirectoryLoadInProgress();

  @override
  List<Object> get props => [
  ];
}

class SyncingDone extends DirectoryState {
  const SyncingDone();

  @override
  List<Object> get props => [
  ];
}

class DirectoryLoadSuccess extends DirectoryState {
  const DirectoryLoadSuccess({
    required this.path,
    required this.contents,
    this.action = '',
  });

  final String path;
  final List<BaseItem> contents;
  final String action;

  @override
  List<Object> get props => [
    path,
    contents,
    action,
  ];
}

class DirectoryLoadFailure extends DirectoryState {
  const DirectoryLoadFailure({
    this.error,
  });

  final String? error;

  @override
  List<Object?> get props => [
    error,
  ];
}
