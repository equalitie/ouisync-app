import 'package:flutter_bloc/flutter_bloc.dart';

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
}

class Job extends Cubit<JobState> {
  Job(int soFar, int total) : super(JobState(soFar: soFar, total: total));

  void update(int soFar) {
    emit(state.copyWith(soFar: soFar));
  }

  void cancel() {
    emit(state.copyWith(cancel: true));
  }
}
