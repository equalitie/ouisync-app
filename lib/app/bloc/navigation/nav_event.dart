import 'package:equatable/equatable.dart';

import '../blocs.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
}

class NavigateTo extends NavigationEvent {
  const NavigateTo({
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
  List<Object?> get props => [
    type,
    origin,
    destination
  ];
}