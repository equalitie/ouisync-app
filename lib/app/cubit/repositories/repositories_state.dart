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
  const RepositoryPickerUnlocked({
    required this.repo,
    required this.previousAccessMode
  });

  final RepoState repo;
  final AccessMode previousAccessMode;

  @override
  List<Object?> get props => [
    repo,
    previousAccessMode
  ];
}

class RepositoriesFailure extends RepositoryPickerState {}
