import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../utils/loggers/ouisync_app_logger.dart';
import '../models/repo_state.dart';

class RepositoryProgressCubit extends Cubit<RepositoryProgressState> with OuiSyncAppLogger {
  RepositoryProgressCubit() : super(RepositoryProgressInitial());

  Future<void> updateProgress(RepoState repository) async {
    final progress = await repository.syncProgress();
    emit(RepositoryProgressUpdate(repository, progress));
  }
}

//------------------------------------------------------------------------------

abstract class RepositoryProgressState extends Equatable {
  const RepositoryProgressState();

  @override
  List<Object?> get props => [];
}

class RepositoryProgressInitial extends RepositoryProgressState { }

class RepositoryProgressUpdate extends RepositoryProgressState {
  const RepositoryProgressUpdate(this.repo, this.progress);

  final RepoState repo;
  final oui.Progress progress;

  @override
  List<Object?> get props => [ repo, progress ];
}
