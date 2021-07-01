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
    required this.navigation,
    required this.parentPath,
    required this.destinationPath
  }) :
  assert (parentPath != ''),
  assert (destinationPath != '');

  final Navigation navigation;
  final String parentPath;
  final String destinationPath;

  @override
  List<Object> get props => [
    navigation,
    parentPath,
    destinationPath
  ];
}

enum Navigation {
  folder,
  file,
  receive_intent,
}