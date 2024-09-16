import 'dart:io';

import 'package:ouisync/ouisync.dart';

import 'log.dart';
import 'native.dart';

/// Utility to mount repositories to the file system on platforms where mounting is supported.
class Mounter with AppLogger {
  Mounter(Session session) : _session = session;

  final Session _session;
  String? _mountPoint;

  Future<void> init() async {
    if (Platform.isMacOS) {
      _mountPoint = await Native.getMountRootDirectory();
      return;
    }

    final mountPoint = _defaultMountPoint;
    if (mountPoint == null) {
      return;
    }

    try {
      await _session.mountAllRepositories(mountPoint);
      _mountPoint = mountPoint;
    } on Error catch (error, st) {
      loggy.error(
        'Failed to init mounter at $mountPoint:',
        error.message,
        st,
      );
      _mountPoint = null;
      rethrow;
    }
  }

  String? get mountPoint => _mountPoint;
}

String? get _defaultMountPoint {
  if (Platform.isLinux || Platform.isMacOS) {
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
