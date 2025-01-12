import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final Object error; // any error can be thrown in dart
  final StackTrace stack;

  const MountStateError(this.error, this.stack);
}

class MountCubit extends Cubit<MountState> with CubitActions, AppLogger {
  final Mounter mounter;

  MountCubit(this.mounter) : super(MountStateDisabled());

  void init() => unawaited(_init());

  Future<void> _init() async {
    emitUnlessClosed(MountStateMounting());

    try {
      await mounter.init();
      emitUnlessClosed(MountStateSuccess());
    } catch (error, stack) {
      emitUnlessClosed(MountStateError(error, stack));
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
