import 'package:loggy/loggy.dart';
import 'package:ouisync_app/app/session.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' show Repository, Session;
import 'package:package_info_plus/package_info_plus.dart';

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
  final logger = Loggy<AppLogger>('background');

  final session = await createSession(
    packageInfo: packageInfo,
    logger: logger,
  );

  logger.info('sync started');

  final start = DateTime.now();

  try {
    final settings = await loadAndMigrateSettings(session);
    final repos = await _fetchRepositories(session, settings);

    await Future.any([
      _waitForAllSynced(repos),
      _waitForSyncInactivity(session),
    ]);

    final elapsed = DateTime.now().difference(start);
    logger.info('sync completed in $elapsed');
  } catch (e, st) {
    logger.error('sync failed', e, st);
  } finally {
    await session.close();
  }
}

Future<List<Repository>> _fetchRepositories(
  Session session,
  Settings settings,
) =>
    Future.wait(
      settings.repos.map((location) async {
        final repo = await Repository.open(session, store: location.path);
        await repo.setSyncEnabled(true);
        return repo;
      }).toList(),
    );

Future<void> _waitForAllSynced(List<Repository> repos) async {
  await Future.wait(repos.map((repo) => _waitForSynced(repo)));
}

Future<void> _waitForSynced(Repository repo) async {
  if (await _isSynced(repo)) {
    return;
  }

  await for (final _ in repo.events) {
    if (await _isSynced(repo)) {
      return;
    }
  }
}

Future<bool> _isSynced(Repository repo) async {
  final progress = await repo.syncProgress;
  return progress.total > 0 && progress.value >= progress.total;
}

Future<void> _waitForSyncInactivity(Session session) async {
  var prev = await session.trafficStats;

  while (true) {
    await Future.delayed(_syncInactivityPeriod);
    final next = await session.trafficStats;

    if (next.send == prev.send && next.recv == prev.recv) {
      return;
    } else {
      prev = next;
    }
  }
}
