part of 'route_bloc.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object> get props => [];
}


class UpdateRoute extends RouteEvent {
  const UpdateRoute({
    required this.path,
    required this.data
  });

  final String path;
  final BaseItem data;

  @override
  List<Object> get props => [
    path,
    data
  ];
}