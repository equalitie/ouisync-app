import 'dart:async';
import 'dart:io';

import 'package:ouisync/ouisync.dart' show Session, initLog;
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';

import 'utils/platform/platform_window_manager.dart';

Future<Session> createSession({
  required PackageInfo packageInfo,
  PlatformWindowManager? windowManager,
  void Function()? onConnectionReset,
}) async {
  final configPath = join(
    await Native.getBaseDir().then((dir) => dir.path),
    Constants.configDirName,
  );

  final logger = appLogger('');

  initLog(
    callback: (level, message) => logger.log(level.toLoggy(), message),
  );

  final session = await Session.create(
    configPath: configPath,
    // On darwin, the server is started by a background process
    startServer: !Platform.isMacOS && !Platform.isIOS,
  );

  try {
    windowManager?.onClose(session.close);

    if (await session.storeDir == null) {
      final dir = await defaultStoreDir;
      await session.setStoreDir(dir.path);
    }

    await session.initNetwork(
      defaultBindAddrs: ['quic/0.0.0.0:0', 'quic/[::]:0'],
      defaultPortForwardingEnabled: true,
      defaultLocalDiscoveryEnabled: true,
    );
  } catch (e) {
    await session.close();
    rethrow;
  }

  return session;
}
