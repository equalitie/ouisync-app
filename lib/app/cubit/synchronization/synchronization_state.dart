part of 'synchronization_cubit.dart';

abstract class SynchronizationState extends Equatable {
  const SynchronizationState();

  @override
  List<Object> get props => [];
}

class SynchronizationInitial extends SynchronizationState {}

class SynchronizationOngoing extends SynchronizationState {}

class SynchronizationDone extends SynchronizationState {}

class SynchronizationFailure extends SynchronizationState {}
