import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'synchronization_state.dart';

class SynchronizationCubit extends Cubit<SynchronizationState> {
  SynchronizationCubit() : super(SynchronizationInitial());

  void syncing() => emit(SynchronizationOngoing());

  void done() => emit(SynchronizationDone());

  void failed() => emit(SynchronizationFailure());
}