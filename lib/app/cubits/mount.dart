import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/dirs.dart';
import '../utils/log.dart';
import '../utils/session_handle.dart';
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

class MountStateFailure extends MountState {
  final Object error; // any error can be thrown in dart
  final StackTrace stack;

  const MountStateFailure(this.error, this.stack);
}

class MountCubit extends Cubit<MountState> with CubitActions, AppLogger {
  final SessionProxy _session;
  final Dirs dirs;

  MountCubit(this._session, this.dirs) : super(MountStateDisabled());

  void init() {
    _session.started.addListener(_onSessionStarted);
    _onSessionStarted();
  }

  Future<void> _init() async {
    emitUnlessClosed(MountStateMounting());
    try {
      if (await _session.getMountRoot() == null) {
        await _session.setMountRoot(dirs.defaultMount);
      }

      final mountRoot = await _session.getMountRoot();

      emitUnlessClosed(
        mountRoot != null ? MountStateSuccess() : MountStateDisabled(),
      );
    } on Unsupported {
      emitUnlessClosed(MountStateDisabled());
    } catch (error, stack) {
      loggy.error(
        "failed to set mount root to ${dirs.defaultMount}:",
        error,
        stack,
      );

      emitUnlessClosed(MountStateFailure(error, stack));
    }
  }

  void _onSessionStarted() {
    if (_session.started.value == 0) {
      return;
    }
    unawaited(_init());
  }

  Future<void> initialized() async {
    if (state is MountStateMounting) {
      await stream.where((state) => state is! MountStateMounting).first;
    }
  }

  @override
  Future<void> close() async {
    _session.started.removeListener(_onSessionStarted);
    await initialized();
    await super.close();
  }
}
