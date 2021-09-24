import 'package:equatable/equatable.dart';

import '../../models/models.dart';

abstract class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object> get props => [];
}

class DirectoryInitial extends DirectoryState {}

class SyncingInProgress extends DirectoryState {
  const SyncingInProgress({
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

class DirectoryLoadInProgress extends DirectoryState {
  const DirectoryLoadInProgress({
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

class SyncingDone extends DirectoryState {
  const SyncingDone({
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

class DirectoryLoadSuccess extends DirectoryState {
  const DirectoryLoadSuccess({
    required this.contents,
    this.action = '',
    this.isSyncing = false
  });

  final List<dynamic> contents;
  final String action;
  final bool isSyncing;

  @override
  List<Object> get props => [
    contents,
    action,
    isSyncing
  ];
}

class NavigationLoadSuccess extends DirectoryState {
  const NavigationLoadSuccess({
    required this.type,
    required this.origin,
    required this.destination,
    required this.contents,
    this.isSyncing = false,
  }) :
  assert (origin != ''),
  assert (destination != '');

  final Navigation type;
  final String origin;
  final String destination;
  final List<BaseItem> contents;
  final bool isSyncing;

  @override
  List<Object> get props => [
    type,
    origin,
    destination,
    contents,
    isSyncing
  ];
}

class DirectoryLoadFailure extends DirectoryState {
  const DirectoryLoadFailure({
    this.isSyncing = false
  });

  final bool isSyncing;

  @override
  List<Object> get props => [
    isSyncing
  ];
}

class NavigationLoadFailure extends DirectoryState {}

enum Navigation {
  content,
  receive_intent,
}

