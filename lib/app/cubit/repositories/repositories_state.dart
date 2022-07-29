part of 'repositories_cubit.dart';

class RepositoriesChanged extends Equatable {
  static int _nextChangeVersion = 0;
  final int _version;

  RepositoriesChanged() : _version = _nextChangeVersion {
    _nextChangeVersion += 1;
  }

  @override
  List<Object?> get props => [ _version ];
}
