import 'package:equatable/equatable.dart';
import 'package:ouisync_app/app/models/models.dart';

import '../blocs.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
}

class NavigateTo extends NavigationEvent {
  const NavigateTo(
    this.navigation,
    this.origin,
    this.destination,
    this.data
  ) : 
  assert (origin != ''),
  assert (destination != '');

  final Navigation navigation;
  final String origin;
  final String destination;
  final BaseItem data;

  @override
  List<Object?> get props => [
    navigation,
    origin,
    destination,
    data
  ];
}