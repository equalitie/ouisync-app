import 'package:equatable/equatable.dart';

import '../../models/models.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationLoadInProgress extends NavigationState {}

class NavigationLoadSuccess extends NavigationState {
  const NavigationLoadSuccess({
    required this.navigation,
    required this.parentPath,
    required this.destinationPath,
    required this.data
  }) :
  assert (parentPath != ''),
  assert (destinationPath != '');

  final Navigation navigation;
  final String parentPath;
  final String destinationPath;
  final BaseItem data;

  @override
  List<Object> get props => [
    navigation,
    parentPath,
    destinationPath,
    data
  ];
}

enum Navigation {
  folder,
  file,
  receive_intent,
}