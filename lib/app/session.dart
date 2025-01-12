import 'dart:async';
import 'dart:io';

import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart' show Session;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';

import 'utils/constants.dart';
import 'utils/log.dart';
import 'utils/native.dart';
import 'utils/platform/platform_window_manager.dart';

Future<Session> createSession(
    {required PackageInfo packageInfo,
    required Loggy logger,
    PlatformWindowManager? windowManager,
    void Function()? onConnectionReset}) async {
  final appDir = await Native.getBaseDir();
  final configPath = join(appDir.path, Constants.configDirName);
  final logPath = await LogUtils.path;

  final session = await Session.create(
    configPath: configPath,
    // On darwin, the serveer is started by a background process
    startServer: !Platform.isMacOS && !Platform.isIOS
  );

  try {
    windowManager?.onClose(session.close);

    // Make sure to only output logs after Session is created (which sets up the log subscriber),
    // otherwise the logs will go nowhere.
    Loggy.initLoggy(logPrinter: AppLogPrinter());

    // When dumping log from logcat, we get logs from past ouisync runs as well,
    // so add a line on each start of the app to know which part of the log
    // belongs to the last app instance.
    logger.info(
        '-------------------- ${packageInfo.appName} Start --------------------');
    logger.debug('app dir: ${appDir.path}');
    logger.debug('log dir: ${File(logPath).parent.path}');

    await session.initNetwork(
      defaultPortForwardingEnabled: true,
      defaultLocalDiscoveryEnabled: true,
    );

    // Add cache servers as user defined peers so we immediately connect to them.
    for (final host in Constants.cacheServers) {
      unawaited(addCacheServerAsPeer(session, host, logger: logger));
    }
  } catch (e) {
    await session.close();
    rethrow;
  }

  return session;
}

const _defaultPeerPort = 20209;

Future<void> addCacheServerAsPeer(
  Session session,
  String host, {
  required Loggy logger,
}) async {
  try {
    for (final addr in await InternetAddress.lookup(_stripPort(host))) {
      for (final proto in ['quic', 'tcp']) {
        await session
            .addUserProvidedPeers(['$proto/${addr.address}:$_defaultPeerPort']);
      }
    }

    logger.debug('cache server $host added');
  } catch (e, st) {
    logger.error('failed to add cache server $host:', e, st);
  }
}

String _stripPort(String addr) {
  final index = addr.lastIndexOf(':');

  if (index >= 0) {
    return addr.substring(0, index);
  } else {
    return addr;
  }
}
