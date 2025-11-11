import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits.dart' show CubitActions;

class JobState {
  int soFar;
  int total;
  bool cancel = false;

  JobState({required this.soFar, required this.total, this.cancel = false});

  JobState copyWith({int? soFar, int? total, bool? cancel}) => JobState(
    soFar: soFar ?? this.soFar,
    total: total ?? this.total,
    cancel: cancel ?? this.cancel,
  );

  double get progress => total > 0 ? soFar / total : 0.0;
}

class Job extends Cubit<JobState> with CubitActions {
  Job(int soFar, int total) : super(JobState(soFar: soFar, total: total));

  void update(int soFar) {
    emitUnlessClosed(state.copyWith(soFar: soFar));
  }

  void cancel() {
    emitUnlessClosed(state.copyWith(cancel: true));
  }
}
