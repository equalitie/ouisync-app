import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class RepositoryEvent extends Equatable {
  const RepositoryEvent();
}

class RepositoryCreate extends RepositoryEvent {
  const RepositoryCreate({
    @required this.repoDir,
    @required this.newRepoRelativePath
  }) :
  assert (repoDir != null),
  assert (repoDir != null),
  assert (newRepoRelativePath != null),
  assert (newRepoRelativePath != null);

  final String repoDir;
  final String newRepoRelativePath;

  @override
  List<Object> get props => [
    repoDir,
    newRepoRelativePath
  ];

}

class RepositoriesRequest extends RepositoryEvent {
  const RepositoriesRequest({
    @required this.repositoriesPath
  }) :
  assert(repositoriesPath != null) ,
  assert(repositoriesPath != "");

  final String repositoriesPath;

  @override
  List<Object> get props => [
    repositoriesPath
  ];

}
