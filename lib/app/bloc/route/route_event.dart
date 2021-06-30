part of 'route_bloc.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object> get props => [];
}


class UpdateRoute extends RouteEvent {
  const UpdateRoute({
    required this.path
  });

  final String path;

  @override
  List<Object> get props => [
    path,
  ];
}