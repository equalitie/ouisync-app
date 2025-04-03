import 'dart:async';
import 'dart:io';

import 'package:ouisync/ouisync.dart' show NetworkDefaults, Session, initLog;
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'utils/dirs.dart';
import 'utils/platform/platform_window_manager.dart';

Future<Session> createSession({
  required PackageInfo packageInfo,
  required Dirs dirs,
  PlatformWindowManager? windowManager,
  void Function()? onConnectionReset,
}) async {
  final logger = appLogger('');

  initLog(
    callback: (level, message) => logger.log(level.toLoggy(), message),
  );

  final session = await Session.create(
    configPath: dirs.config,
    // On darwin, the server is started by a background process
    startServer: !Platform.isMacOS && !Platform.isIOS,
    debugLabel: Platform.environment['OUISYNC_DEBUG_LABEL'],
  );

  try {
    windowManager?.onClose(session.close);

    if (await session.getStoreDir() == null) {
      await session.setStoreDir(dirs.defaultStore);
    }

    await session.initNetwork(NetworkDefaults(
      bind: ['quic/0.0.0.0:0', 'quic/[::]:0'],
      portForwardingEnabled: true,
      localDiscoveryEnabled: true,
    ));
  } catch (e) {
    await session.close();
    rethrow;
  }

  return session;
}
