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
    this.repository,
    required this.name
  });

  final Repository? repository;
  final String name;

  @override
  List<Object?> get props => [
    repository,
    name
  ];
}

class RepositoriesFailure extends RepositoryPickerState {}
