import 'dart:io' show Platform;

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
  String get defaultStore => join(root, 'repositories');

  /// Default directory for mounting repositories (if mounting is supported on the platform)
  final String? defaultMount;

  /// Download directory.
  final String? download;

  Dirs({
    required String root,
    this.defaultMount,
    this.download,
  }) : root = canonicalize(root);

  /// Initialize the `Dirs` with default directories. Specify `root` to override the default data
  /// root directory. `root` can also be overriden using the `OUISYNC_ROOT_DIR` env variable.
  static Future<Dirs> init({String? root}) async {
    return Dirs(
      root: root ??
          Platform.environment['OUISYNC_ROOT_DIR'] ??
          await Native.getBaseDir().then((dir) => dir.path),
      defaultMount: await _getDefaultMountDir(),
      download: await _getDownloadDir(),
    );
  }
}

Future<String?> _getDownloadDir() async {
  if (Platform.isAndroid) {
    return await Native.getDownloadPathForAndroid();
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
    return 'O:';
  } else {
    return null;
  }
}
