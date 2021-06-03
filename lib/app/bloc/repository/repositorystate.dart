import 'package:equatable/equatable.dart';

import '../../models/models.dart';

abstract class RepositoryState extends Equatable {
  const RepositoryState();

  @override
  List<Object> get props => [];
}

class RepositoryInitial extends RepositoryState {}

class RepositoryLoadInProgress extends RepositoryState {}

class RepositoryLoadSuccess extends RepositoryState {
  const RepositoryLoadSuccess({
    required this.repositories
  }) : assert(repositories != null);

  final List<BaseItem> repositories;

  @override
  List<Object> get props => [
    repositories
  ];
}

class RepositoryLoadFailure extends RepositoryState {}