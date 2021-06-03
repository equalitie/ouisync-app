import 'package:equatable/equatable.dart';

abstract class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object> get props => [];
}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoadInProgress extends DirectoryState {}

class DirectoryLoadSuccess extends DirectoryState {
  const DirectoryLoadSuccess({
    required this.contents
  });

  final List<dynamic> contents;

  @override
  List<Object> get props => [
    contents
  ];
}

class DirectoryLoadFailure extends DirectoryState {}

