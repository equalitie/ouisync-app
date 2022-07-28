part of 'repositories_cubit.dart';

abstract class RepositoryPickerState extends Equatable {
  const RepositoryPickerState();

  @override
  List<Object?> get props => [];
}

class RepositoryPickerInitial extends RepositoryPickerState {}

class RepositoryPickerLoading extends RepositoryPickerState {}

class RepositoryPickerSelection extends RepositoryPickerState {
  const RepositoryPickerSelection(this.repo);

  final RepoState repo;

  @override
  List<Object?> get props => [
    repo,
  ];
}

class RepositoryPickerUnlocked extends RepositoryPickerState {
  const RepositoryPickerUnlocked(this.repo);

  final RepoState repo;

  @override
  List<Object?> get props => [
    repo,
  ];
}

class RepositoriesFailure extends RepositoryPickerState {}
