import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
}

class NavigateTo extends NavigationEvent {
  const NavigateTo(
    this.origin,
    this.destination
  ) : 
  assert (origin != ''),
  assert (destination != '');

  final String origin;
  final String destination;

  @override
  List<Object?> get props => [
    origin,
    destination
  ];
}