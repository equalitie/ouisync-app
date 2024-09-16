import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/log.dart';
import '../utils/mounter.dart';
import 'utils.dart';

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
  final ErrorCode code;
  final String message;

  const MountStateError(this.code, this.message);
}

class MountCubit extends Cubit<MountState> with AppLogger {
  final Mounter mounter;

  MountCubit(this.mounter) : super(MountStateDisabled());

  void init() => unawaited(_init());

  Future<void> _init() async {
    emitUnlessClosed(MountStateMounting());

    try {
      await mounter.init();
      emitUnlessClosed(MountStateSuccess());
    } on Error catch (error) {
      emitUnlessClosed(MountStateError(error.code, error.message));
    }
  }

  @override
  Future<void> close() async {
    if (state is MountStateMounting) {
      await stream.where((state) => state is! MountStateMounting).first;
    }

    await super.close();
  }
}
