import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart'
    show Repository, RepositoryExtension, Session;
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'session.dart';
import 'utils/constants.dart';
import 'utils/dirs.dart';
import 'utils/log.dart';
import 'utils/settings/settings.dart';

/// If not data is sent or received within this period we consider the sync to be complete (either
/// because everything has been synced or because no peer has anything we need).
const _syncInactivityPeriod = Duration(seconds: 30);

/// This function gets called periodically to ensure syncing happens even when the app is in the
/// background.
@pragma('vm:entry-point')
Future<void> syncInBackground() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final dirs = await Dirs.init();
  final logger = Loggy<AppLogger>('background');

  final session = await createSession(packageInfo: packageInfo, dirs: dirs);

  final cacheServers = CacheServers(session);
  await cacheServers.addAll(Constants.cacheServers);

  logger.info('sync started');

  final start = DateTime.now();

  try {
    await loadAndMigrateSettings(session);
    final repos =
        await session.listRepositories().then((repos) => repos.values.toList());

    final completed = await Future.any([
      _waitForAllSynced(repos).then((_) => true),
      _waitForSyncInactivity(session).then((_) => false),
    ]);

    final elapsed = DateTime.now().difference(start);

    if (completed) {
      logger.info('sync completed in $elapsed');
    } else {
      logger.info('sync stopped for inactivity after $elapsed');
    }
  } catch (e, st) {
    logger.error('sync failed:', e, st);
  } finally {
    await session.close();
  }
}

Future<void> _waitForAllSynced(List<Repository> repos) async {
  await Future.wait(repos.map((repo) => _waitForSynced(repo)));
}

Future<void> _waitForSynced(Repository repo) async {
  // This future completes when the repo gets synced after receiving at least one repo
  // event. This also creates the repo event subscription. Doing this before checking if the
  // repo is already synced, to prevent race condition.
  final syncedAfterEvent = repo.events
      .asyncMap((_) => _isSynced(repo))
      .where((synced) => synced)
      .first;

  if (await _isSynced(repo)) {
    return;
  }

  await syncedAfterEvent;
}

Future<bool> _isSynced(Repository repo) async {
  final progress = await repo.getSyncProgress();
  return progress.total > 0 && progress.value >= progress.total;
}

Future<void> _waitForSyncInactivity(Session session) async {
  var prev = await session.getNetworkStats();

  while (true) {
    await Future.delayed(_syncInactivityPeriod);
    final next = await session.getNetworkStats();

    if (next.bytesTx == prev.bytesTx && next.bytesRx == prev.bytesRx) {
      return;
    } else {
      prev = next;
    }
  }
}
