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
    required this.contents,
    this.action = ''
  });

  final List<dynamic> contents;
  final String action;

  @override
  List<Object> get props => [
    contents,
    action
  ];
}

class DirectoryLoadFailure extends DirectoryState {}

