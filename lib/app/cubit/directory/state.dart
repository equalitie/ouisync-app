import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/repo_state.dart';

abstract class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object?> get props => [];
}

enum DownloadFileResult {
  done,
  canceled,
  failed
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

class ShowMessage extends DirectoryState {
  const ShowMessage(this.message);

  final String message;

  @override
  List<Object> get props => [ message ];
}

class WriteToFileInProgress extends DirectoryState {
  const WriteToFileInProgress({
    required this.repository,
    required this.path,
    required this.fileName,
    required this.length,
    required this.progress
  });

  final RepoState repository;
  final String path;
  final String fileName;
  final int length;
  final int progress;

  @override
  List<Object> get props => [
    repository,
    path,
    fileName,
    length,
    progress
  ];
}

class WriteToFileDone extends DirectoryState {
  const WriteToFileDone({
    required this.repository,
    required this.path
  });

  final RepoState repository;
  final String path;

  @override
  List<Object> get props => [ repository, path ];
}

class DownloadFileInProgress extends DirectoryState {
  const DownloadFileInProgress({
    required this.repository,
    required this.path,
    required this.fileName,
    required this.length,
    required this.progress
  });

  final RepoState repository;
  final String path;
  final String fileName;
  final int length;
  final int progress;

  @override
  List<Object> get props => [
    repository,
    path,
    fileName,
    length,
    progress
  ];
}

class DownloadFileDone extends DirectoryState {
  const DownloadFileDone({ 
    required this.repository,
    required this.path,
    required this.devicePath,
    required this.result
  });

  final RepoState repository;
  final String path;
  final String devicePath;
  final DownloadFileResult result;

  @override
  List<Object> get props => [ repository, path, devicePath, result ];
}

class DirectoryLoadInProgress extends DirectoryState {
  const DirectoryLoadInProgress();

  @override
  List<Object> get props => [ ];
}

class DirectoryReloaded extends DirectoryState {
  const DirectoryReloaded({
    required this.id,
    required this.path,
  });

  // NOTE: We need this id to change every time we want the bloc receiver to
  // receive this new state. Otherwise the receiver would assume that the state
  // hasn't changed and woul not rebuild the widget.
  final int id;
  final String path;

  @override
  List<Object> get props => [
    id,
    path,
  ];
}
