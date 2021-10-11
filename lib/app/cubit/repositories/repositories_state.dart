part of 'repositories_cubit.dart';

abstract class RepositoriesState extends Equatable {
  const RepositoriesState();

  @override
  List<Object> get props => [];
}

class RepositoriesInitial extends RepositoriesState {}

class RepositoriesLoading extends RepositoriesState {}

class RepositoriesSelection extends RepositoriesState {
  const RepositoriesSelection({
    this.repository,
    required this.name
  });

  final Repository? repository;
  final String name;

  @override
  List<Object> get props => [
    repository!,
    name
  ];
}

class RepositoriesFailure extends RepositoriesState {}
