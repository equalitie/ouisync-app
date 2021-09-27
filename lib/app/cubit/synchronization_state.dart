import 'package:equatable/equatable.dart';

abstract class SynchronizationState extends Equatable {
  const SynchronizationState();

  @override
  List<Object> get props => [];
}

class SynchronizationInitial extends SynchronizationState {}

class SynchronizationNotification extends SynchronizationState {
  const SynchronizationNotification({
    required this.contents,
  });

  final List<dynamic> contents;

  @override
  List<Object> get props => [
    contents,
  ];
}

class SynchronizationFailure extends SynchronizationState {}
