import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/log.dart';
import '../utils/native.dart';
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
  final OuisyncException exception;

  const MountStateFailure(this.exception);
}

class MountCubit extends Cubit<MountState> with CubitActions, AppLogger {
  final Session session;

  MountCubit(this.session) : super(MountStateDisabled());

  void init() => unawaited(_init());

  Future<void> _init() async {
    emitUnlessClosed(MountStateMounting());

    try {
      final mountRoot = await _defaultMountRoot;
      await session.setMountRoot(mountRoot);

      emitUnlessClosed(
        mountRoot != null ? MountStateSuccess() : MountStateDisabled(),
      );
    } on OuisyncException catch (error) {
      emitUnlessClosed(MountStateFailure(error));
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

Future<String?> get _defaultMountRoot async {
  if (Platform.isMacOS) {
    return await Native.getMountRootDirectory();
  }

  if (Platform.isLinux) {
    final home = Platform.environment['HOME'];

    if (home == null) {
      return null;
    }

    return '$home/Ouisync';
  } else if (Platform.isWindows) {
    return 'O:';
  } else {
    return null;
  }
}
