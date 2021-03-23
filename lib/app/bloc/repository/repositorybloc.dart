import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import '../../data/repositories/ouisyncrepository.dart';
import '../../models/models.dart';
import '../blocs.dart';


class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  RepositoryBloc({
    @required this.repository
  }) : 
  assert(repository != null),
  super(RepositoryInitial());

  final OuisyncRepository repository;

  @override
  Stream<RepositoryState> mapEventToState(RepositoryEvent event) async* {
    if (event is RepositoryCreate) {
      yield RepositoryLoadInProgress();

      try {
        repository.createRepository(event.repoDir, event.newRepoRelativePath);
        final List<BaseItem> repos = await repository.getRepositories(event.repoDir);
        
        yield RepositoryLoadSuccess(repositories: repos);
      } catch (e) {
        print('Exception creating a new repository (${event.newRepoRelativePath}) in ${event.repoDir}:\n${e.toString()}');
        yield RepositoryLoadFailure();
      }
    }

    if (event is RepositoriesRequest) {
      yield RepositoryLoadInProgress();
      
      try {
        final List<BaseItem> repos = await repository.getRepositories(event.repositoriesPath);
        yield RepositoryLoadSuccess(repositories: repos);
      } catch (e) {
        print('Exception getting the repositories from ${event.repositoriesPath}:\n${e.toString()}');
        yield RepositoryLoadFailure();
      }
    }
  }
}
