part of 'repositories_cubit.dart';

abstract class RepositoryPickerState extends Equatable {
  const RepositoryPickerState();

  @override
  List<Object?> get props => [];
}

class RepositoryPickerInitial extends RepositoryPickerState {}

class RepositoryPickerLoading extends RepositoryPickerState {}

class RepositoryPickerSelection extends RepositoryPickerState {
  const RepositoryPickerSelection(this.named_repo);

  final NamedRepo named_repo;

  @override
  List<Object?> get props => [
    named_repo,
  ];
}

class RepositoryPickerUnlocked extends RepositoryPickerState {
  const RepositoryPickerUnlocked({
    required this.named_repo,
    required this.previousAccessMode
  });

  final NamedRepo named_repo;
  final AccessMode previousAccessMode;

  @override
  List<Object?> get props => [
    named_repo,
    previousAccessMode
  ];
}

class RepositoriesFailure extends RepositoryPickerState {}
