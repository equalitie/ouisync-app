import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' as oui;

import '../utils/log.dart';

sealed class MountState {
  const MountState();
}

class MountStateDisabled extends MountState {
  const MountStateDisabled();
}

class MountStateMounting extends MountState {
  const MountStateMounting();
}

class MountStateSuccess extends MountState {
  const MountStateSuccess();
}

class MountStateError extends MountState {
  final oui.ErrorCode code;
  final String message;

  const MountStateError(this.code, this.message);
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
