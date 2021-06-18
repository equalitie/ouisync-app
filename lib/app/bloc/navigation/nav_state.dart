import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  const NavigationState(
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