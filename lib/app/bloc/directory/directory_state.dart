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
    required this.fileName,
    required this.path,
    required this.extension
  });

  final String fileName;
  final String path;
  final String extension;

  @override
  List<Object> get props => [
    fileName,
    path,
    extension
  ];
}

class CreateFileFailure extends DirectoryState {
  const CreateFileFailure({
    required this.filePath,
    required this.fileName,
    required this.length,
    required this.error
  });

  final String filePath;
  final String fileName;
  final int length;
  final String error;

  @override
  List<Object> get props => [
    filePath,
    fileName,
    length,
    error
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
    required this.filePath,
    required this.fileName,
    required this.length
  });

  final String filePath;
  final String fileName;
  final int length;

  @override
  List<Object> get props => [
    filePath,
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
    required this.filePath,
    required this.fileName,
    required this.length,
    required this.error
  });

  final String filePath;
  final String error;
  final String fileName;
  final int length;

  @override
  List<Object> get props => [
    filePath,
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

class NavigationLoadSuccess extends DirectoryState {
  const NavigationLoadSuccess({
    required this.origin,
    required this.destination,
    required this.contents,
  }) :
  assert (origin != ''),
  assert (destination != '');

  final String origin;
  final String destination;
  final List<BaseItem> contents;

  @override
  List<Object> get props => [
    origin,
    destination,
    contents,
  ];
}

class NavigationLoadBlind extends DirectoryState {
  NavigationLoadBlind({
    this.previousAccessMode
  });

  final AccessMode? previousAccessMode;

  @override
  List<Object?> get props => [
    previousAccessMode
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

class NavigationLoadFailure extends DirectoryState {}
