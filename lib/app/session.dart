import 'dart:io';

import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' show Session;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'utils/constants.dart';
import 'utils/log.dart';
import 'utils/platform/platform_window_manager.dart';

Future<Session> createSession({
  required PackageInfo packageInfo,
  PlatformWindowManager? windowManager,
}) async {
  final appDir = await getApplicationSupportDirectory();
  final configPath = join(appDir.path, Constants.configDirName);
  final logPath = await LogUtils.path;

  final session = Session.create(
    configPath: configPath,
    logPath: logPath,
  );

  windowManager?.onClose(session.close);

  // Make sure to only output logs after Session is created (which sets up the log subscriber),
  // otherwise the logs will go nowhere.
  Loggy.initLoggy(logPrinter: AppLogPrinter());

  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  logInfo(
      '-------------------- ${packageInfo.appName} Start --------------------');
  logDebug('app dir: ${appDir.path}');
  logDebug('log dir: ${File(logPath).parent.path}');

  await session.initNetwork(
    defaultPortForwardingEnabled: true,
    defaultLocalDiscoveryEnabled: true,
  );

  for (final host in Constants.storageServers) {
    try {
      await session.addStorageServer(host);
    } catch (e) {
      logError('failed to add storage server $host:', e);
    }
  }

  return session;
}

/// This function gets called periodically to ensure syncing happens even when the app is in the
/// background.
@pragma('vm:entry-point')
void syncInBackground() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final session = await createSession(packageInfo: packageInfo);

  logInfo('Background sync started');

  for (var i = 0; i < 10; ++i) {
    await Future.delayed(Duration(seconds: 1));
    logInfo('Background sync tick');
  }

  logInfo('Background sync complete');

  await session.close();
}
