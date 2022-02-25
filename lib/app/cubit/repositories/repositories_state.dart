part of 'repositories_cubit.dart';

abstract class RepositoryPickerState extends Equatable {
  const RepositoryPickerState();

  @override
  List<Object?> get props => [];
}

class RepositoryPickerInitial extends RepositoryPickerState {}

class RepositoryPickerLoading extends RepositoryPickerState {}

class RepositoryPickerSelection extends RepositoryPickerState {
  const RepositoryPickerSelection({
    required this.repository,
    required this.name
  });

  final Repository? repository;
  final String? name;

  @override
  List<Object?> get props => [
    repository,
    name
  ];
}

class RepositoryPickerUnlocked extends RepositoryPickerState {
  const RepositoryPickerUnlocked({
    required this.repository,
    required this.repositoryName,
    required this.previousAccessMode
  });

  final Repository repository;
  final String repositoryName;
  final AccessMode previousAccessMode;

  @override
  List<Object?> get props => [
    repository,
    repositoryName,
    previousAccessMode
  ];
}

class RepositoriesFailure extends RepositoryPickerState {}
