import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../data/data.dart';
import '../../models/models.dart';
import '../blocs.dart';


class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  RepositoryBloc({
    required this.blocRepository
  }) : 
  assert(blocRepository != null),
  super(RepositoryInitial());

  final OuisyncRepository blocRepository;

  @override
  Stream<RepositoryState> mapEventToState(RepositoryEvent event) async* {
    if (event is CreateRepository) {
      yield RepositoryLoadInProgress();

      try {
        blocRepository.createRepository();
        final List<BaseItem> repos = await blocRepository.getRepositories();
        
        yield RepositoryLoadSuccess(repositories: repos);
      } catch (e) {
        print('Exception creating a new repository:\n${e.toString()}');
        yield RepositoryLoadFailure();
      }
    }

    if (event is RequestContents) {
      yield RepositoryLoadInProgress();
      
      try {
        final List<BaseItem> repos = await blocRepository.getRepositories();
        yield RepositoryLoadSuccess(repositories: repos);
      } catch (e) {
        print('Exception getting the repositories from ${event.repository}:\n${e.toString()}');
        yield RepositoryLoadFailure();
      }
    }
  }
}
