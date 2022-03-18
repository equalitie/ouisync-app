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
    required this.action
  });

  final String path;
  final Function action;

  @override
  List<Object> get props => [
    path, action
  ];
}
