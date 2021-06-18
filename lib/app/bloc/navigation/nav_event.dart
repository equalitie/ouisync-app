import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
}

class NavigateTo extends NavigationEvent {
  const NavigateTo({
    required this.destination
  }) : 
  assert (destination != '');

  final String destination;

  @override
  List<Object?> get props => [
    destination
  ];
}