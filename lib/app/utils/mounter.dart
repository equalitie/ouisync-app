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
    _mountPoint = null;

    // darwin is pre-mounted by the fileprovider extension
    if (Platform.isMacOS || Platform.isIOS) {
      _mountPoint = await Native.getMountRootDirectory();
      return;
    }

    // FIXME: mountPoint is no longer sent to the library
    final mountPoint = _defaultMountPoint;
    if (mountPoint == null) {
      loggy.warning('Unable to determine default mount point');
      return;
    }

    List<Repository> mounted = [];
    for (final repo in await Repository.list(_session)) {
      try {
        await repo.mount();
        mounted.add(repo);
      } catch(error, stack) {
        loggy.error('Failed to mount $repo at $mountPoint:', error, stack);
        // rollback (best-effort) then rethrow
        for (final repo in mounted) {
          try {
            await repo.unmount();
          } catch(error, stack) {
            loggy.error('Failed to unmount previously mounted $repo:',
                        error, stack);
          }
        }
        rethrow;
      }
    }
    _mountPoint = mountPoint;
  }

  String? get mountPoint => _mountPoint;
}

String? get _defaultMountPoint {
  if (Platform.isLinux) {
    final home = Platform.environment['HOME'];
    if (home != null) { return '$home/Ouisync'; }
  }

  if (Platform.isWindows) {
    return 'O:';
  }

  return null;
}
