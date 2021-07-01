import 'package:equatable/equatable.dart';

import '../blocs.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
}

class NavigateTo extends NavigationEvent {
  const NavigateTo(
    this.navigation,
    this.origin,
    this.destination
  ) : 
  assert (origin != ''),
  assert (destination != '');

  final Navigation navigation;
  final String origin;
  final String destination;

  @override
  List<Object?> get props => [
    navigation,
    origin,
    destination
  ];
}