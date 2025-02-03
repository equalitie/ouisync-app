import 'dart:io' show Platform;

import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'native.dart';

/// Utility for platform independent access to various application directories.
class Dirs {
  /// Root data directory.
  final String root;

  /// Ouisync config directory (subdirectory of `root`).
  final String config;

  /// Default directory for storing repositories (subdirectory of `root`).
  final String defaultStore;

  /// Default directory for mounting repositories (if mounting is supported on the platform)
  final String? defaultMount;

  /// Download directory.
  final String? download;

  Dirs({
    required this.root,
    this.defaultMount,
    this.download,
  })  : config = join(root, 'configs'),
        defaultStore = join(root, 'repositories');

  /// Initialize the `Dirs` with default directories. Specify `root` to override the default data
  /// root directory.
  static Future<Dirs> init({String? root}) async {
    return Dirs(
      root: root ?? await Native.getBaseDir().then((dir) => dir.path),
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
