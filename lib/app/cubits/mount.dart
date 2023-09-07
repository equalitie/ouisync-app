import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../utils/log.dart';

class MountState {}

class MountStateDisabled extends MountState {}

class MountStateMounting extends MountState {}

class MountStateSuccess extends MountState {}

class MountStateError extends MountState {
  int code;
  String message;
  MountStateError(this.code, this.message);
}

class MountCubit extends Cubit<MountState> with AppLogger {
  final oui.Session session;

  MountCubit(this.session) : super(MountStateDisabled());

  Future<void> mount(String mountPoint) async {
    emit(MountStateMounting());

    try {
      await session.mountAllRepositories(mountPoint);
      emit(MountStateSuccess());
    } on oui.Error catch (error, st) {
      loggy.error(
        'Failed to mount repositories at $mountPoint:',
        error.message,
        st,
      );
      emit(MountStateError(error.code, error.message));
    }
  }
}
