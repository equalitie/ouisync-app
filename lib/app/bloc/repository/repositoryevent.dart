import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

abstract class RepositoryEvent extends Equatable {
  const RepositoryEvent();
}

class CreateRepository extends RepositoryEvent {
  const CreateRepository({
    required this.session
  });

  final Session session;

  @override
  List<Object> get props => [
    session
  ];

}

class RequestContents extends RepositoryEvent {
  const RequestContents({
    required this.repository
  }) :
  assert(repository != null);

  final Repository repository;

  @override
  List<Object> get props => [
    repository
  ];

}
