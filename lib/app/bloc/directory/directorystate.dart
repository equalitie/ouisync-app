import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/models/models.dart';

abstract class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object> get props => [];
}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoadInProgress extends DirectoryState {}

class DirectoryLoadSuccess extends DirectoryState {
  const DirectoryLoadSuccess({
    @required this.contents
  }) : assert(contents != null);

  final List<BaseItem> contents;

  @override
  List<Object> get props => [
    contents
  ];
}

class DirectoryLoadFailure extends DirectoryState {}

