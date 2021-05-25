import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import '../../data/data.dart';
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
    if (event is CreateRepository) {
      yield RepositoryLoadInProgress();

      try {
        repository.createRepository();
        final List<BaseItem> repos = await repository.getRepositories();
        
        yield RepositoryLoadSuccess(repositories: repos);
      } catch (e) {
        print('Exception creating a new repository:\n${e.toString()}');
        yield RepositoryLoadFailure();
      }
    }

    if (event is RequestContents) {
      yield RepositoryLoadInProgress();
      
      try {
        final List<BaseItem> repos = await repository.getRepositories();
        yield RepositoryLoadSuccess(repositories: repos);
      } catch (e) {
        print('Exception getting the repositories from ${event.repository}:\n${e.toString()}');
        yield RepositoryLoadFailure();
      }
    }
  }
}
