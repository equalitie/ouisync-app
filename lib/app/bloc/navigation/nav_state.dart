import 'package:equatable/equatable.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationLoadInProgress extends NavigationState {}

class NavigationLoadSuccess extends NavigationState {
  const NavigationLoadSuccess({
    required this.type,
    required this.origin,
    required this.destination
  }) :
  assert (origin != ''),
  assert (destination != '');

  final Navigation type;
  final String origin;
  final String destination;

  @override
  List<Object> get props => [
    type,
    origin,
    destination
  ];
}

class NavigationLoadFailure extends NavigationState {}

enum Navigation {
  content,
  receive_intent,
}