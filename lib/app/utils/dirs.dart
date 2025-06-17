import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:path/path.dart' show canonicalize, join;
import 'package:path_provider/path_provider.dart';

import 'native.dart';

/// Utility for platform independent access to various application directories.
class Dirs {
  /// Root data directory.
  final String root;

  /// Ouisync config directory (subdirectory of `root`).
  String get config => join(root, 'configs');

  /// Default directory for storing repositories (subdirectory of `root`).
  final String defaultStore;

  /// Default directory for mounting repositories (if mounting is supported on the platform)
  final String? defaultMount;

  /// Download directory.
  final String? download;

  Dirs._({
    required String root,
    String? defaultStore,
    this.defaultMount,
    this.download,
  }) : root = canonicalize(root),
       defaultStore = defaultStore ?? join(root, 'repositories');

  /// Initialize the `Dirs` with default directories. Specify `root` to override the default data
  /// root directory. `root` can also be overriden using the `OUISYNC_ROOT_DIR` env variable.
  static Future<Dirs> init({String? root}) async {
    root ??= await _getDefaultRootDir();

    return Dirs._(
      root: root,
      defaultStore: await _getDefaultStoreDir(root),
      defaultMount: await _getDefaultMountDir(),
      download: await _getDownloadDir(),
    );
  }
}

Future<String> _getDefaultRootDir() async =>
    Platform.environment['OUISYNC_ROOT_DIR'] ??
    await Native.getBaseDir().then((dir) => dir.path);

const _storeDirName = 'repositories';

Future<String> _getDefaultStoreDir(String root) async {
  final base =
      (Platform.isAndroid
          ? await getExternalStorageDirectory().then((dir) => dir?.path)
          : null) ??
      root;

  return join(base, _storeDirName);
}

Future<String?> _getDownloadDir() async {
  if (Platform.isAndroid) {
    try {
      return await Native.getDownloadPathForAndroid();
    } on MissingPluginException {
      // HACK: The method channel handler is defined in `MainActivity` which is not available
      // when this is accessed from the background service. Catching and returning `null` should be
      // fine in this case as the background doesn't need to access the downloads dir anyway.
      return null;
    }
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory().then((dir) => dir.path);
  } else {
    return await getDownloadsDirectory().then((dir) => dir?.path);
  }
}

Future<String?> _getDefaultMountDir() async {
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
    return 'O:\\';
  } else {
    return null;
  }
}
