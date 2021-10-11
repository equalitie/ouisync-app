part of 'route_bloc.dart';

abstract class RouteState extends Equatable {
  const RouteState();
  
  @override
  List<Object> get props => [];
}

class RouteInitial extends RouteState {}

class RouteLoadSuccess extends RouteState {
  const RouteLoadSuccess({
    required this.path,
    required this.route
  });

  final String path;
  final Widget route;

  @override
  List<Object> get props => [
    path,
    route
  ];
}
