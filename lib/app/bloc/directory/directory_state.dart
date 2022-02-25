import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';

abstract class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object?> get props => [];
}

class DirectoryInitial extends DirectoryState {}

class SyncingInProgress extends DirectoryState {
  const SyncingInProgress({
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

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
  const DirectoryLoadInProgress({
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

class SyncingDone extends DirectoryState {
  const SyncingDone({
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

class DirectoryLoadSuccess extends DirectoryState {
  const DirectoryLoadSuccess({
    required this.path,
    required this.contents,
    this.action = '',
    this.isSyncing = false
  });

  final String path;
  final List<dynamic> contents;
  final String action;
  final bool isSyncing;

  @override
  List<Object> get props => [
    path,
    contents,
    action,
    isSyncing
  ];
}

class NavigationLoadSuccess extends DirectoryState {
  const NavigationLoadSuccess({
    required this.type,
    required this.origin,
    required this.destination,
    required this.contents,
    this.isSyncing = false,
  }) :
  assert (origin != ''),
  assert (destination != '');

  final Navigation type;
  final String origin;
  final String destination;
  final List<BaseItem> contents;
  final bool isSyncing;

  @override
  List<Object> get props => [
    type,
    origin,
    destination,
    contents,
    isSyncing
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
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

class NavigationLoadFailure extends DirectoryState {}

enum Navigation {
  content,
  receive_intent,
}

