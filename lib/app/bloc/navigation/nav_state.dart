import 'package:equatable/equatable.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

class NavigateToInProgress extends NavigationState { }

class NavigateToSucess extends NavigationState {
  const NavigateToSucess(
    this.parentPath,
    this.destinationPath
  ) :
  assert (parentPath != ''),
  assert (destinationPath != '');

  final String parentPath;
  final String destinationPath;

  @override
  List<Object> get props => [
    parentPath,
    destinationPath
  ];
}

class NavigateToFailure extends NavigationState { }