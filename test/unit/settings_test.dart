import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/app/utils/settings/v0/v0.dart' as v0;
import 'package:ouisync_app/app/utils/settings/v1.dart' as v1;
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync/ouisync.dart' show Session;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Run with `flutter test test/settings_test.dart`.
void main() {
  test('settings migration v0 to v1', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().isEmpty, true);

    final baseDir = await getApplicationSupportDirectory();
    await baseDir.create(recursive: true);

    final fooPath = join(baseDir.path, 'foo.db');
    final barPath = join(baseDir.path, 'bar.db');

    final s0 = await v0.Settings.init(prefs);

    await s0.setEqualitieValues(true);
    await s0.setShowOnboarding(false);
    await s0.setLaunchAtStartup(true);
    await s0.setSyncOnMobileEnabled(true);
    await s0.setHighestSeenProtocolNumber(1);
    await s0.addRepo(
      RepoLocation.fromDbPath(fooPath),
      databaseId: '123',
      authenticationMode: v0.AuthMode.manual,
    );
    await s0.setDefaultRepo('foo');

    final session =
        await Session.create(configPath: join(baseDir.path, 'config'));

    await session.createRepository(
      path: fooPath,
      readSecret: null,
      writeSecret: null,
    );

    final s1 = await loadAndMigrateSettings(session);

    await prefs.reload();

    // In version 1 we only expect the "settings" value to be present.
    expect(prefs.getKeys().length, 1);
    expect(s1.repos, unorderedEquals([RepoLocation.fromDbPath(fooPath)]));

    // The auth mode should have been transferred to the repo metadata
    final repo = await session.openRepository(path: fooPath);
    expect(await repo.getAuthMode(), isA<AuthModeBlindOrManual>());

    await s1.setRepoLocation(
      DatabaseId("234"),
      RepoLocation.fromDbPath(barPath),
    );

    expect(
      s1.repos,
      unorderedEquals([
        RepoLocation.fromDbPath(fooPath),
        RepoLocation.fromDbPath(barPath),
      ]),
    );
  });

  test('settings migration v1 to v2', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().isEmpty, true);

    final baseDir = await getApplicationSupportDirectory();
    await baseDir.create(recursive: true);

    final fooPath = join(baseDir.path, 'foo.db');
    final barPath = join(baseDir.path, 'bar.db');

    final masterKey = MasterKey.random();
    final s1 = await v1.Settings.init(masterKey);

    final repoLocation = RepoLocation.fromDbPath(fooPath);

    await s1.setEqualitieValues(true);
    await s1.setShowOnboarding(false);
    await s1.setSyncOnMobileEnabled(true);
    await s1.setHighestSeenProtocolNumber(1);
    await s1.setRepoLocation(DatabaseId('123'), repoLocation);
    await s1.setDefaultRepo(repoLocation);

    final session =
        await Session.create(configPath: join(baseDir.path, 'config'));

    await session.createRepository(
      path: fooPath,
      readSecret: null,
      writeSecret: null,
    );

    final s2 = await loadAndMigrateSettings(session);

    expect(s2.getSyncOnMobileEnabled(), false);

    await prefs.reload();

    // In version 1 we only expect the "settings" value to be present.
    expect(prefs.getKeys().length, 1);
    expect(s2.repos, unorderedEquals([RepoLocation.fromDbPath(fooPath)]));

    // The auth mode should have been transfered to the repo metadata
    final repo = await session.openRepository(path: fooPath);
    expect(await repo.getAuthMode(), isA<AuthModeBlindOrManual>());

    await s2.setRepoLocation(
      DatabaseId("234"),
      RepoLocation.fromDbPath(barPath),
    );

    expect(
      s2.repos,
      unorderedEquals([
        RepoLocation.fromDbPath(fooPath),
        RepoLocation.fromDbPath(barPath),
      ]),
    );
  });

  test('master key', () async {
    FlutterSecureStorage.setMockInitialValues({});

    final key = await MasterKey.init();

    final encrypted = await key.encrypt("foobar");
    final decrypted = await key.decrypt(encrypted);

    expect(decrypted, "foobar");
  });

  //
  // It sometimes happens that crypto libraries change default parameters in
  // their encryption algorithms which would make the master key unusable. So
  // check here if what we could encrypt in previous version can still be
  // decrypted.
  //
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // !!!! If this test fails, we need to implement settings migrations, !!!!
  // !!!! not just change the test.                                     !!!!
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //
  test('compatible encryption', () async {
    final teststring = "foobar";

    ////Use this commented code if you need to generate new values.
    //{
    //  final rawKey = MasterKey.generateKey();
    //  debugPrint("key: $rawKey");
    //  final key = MasterKey.initWithKey(rawKey);
    //  final encrypted = await key.encrypt(teststring);
    //  debugPrint("encrypted: $encrypted");
    //}

    final key =
        MasterKey.initWithKey("eZcpF/CdFblXXhFP4LHk49lGtDEY4c1Gn/qQKBU0QmA=");

    final encrypted = "cKMbibnjHsni8olld2sUXjxNsAroR/DOKNj3rUOOrFtUrA==";

    expect(await key.decrypt(encrypted), teststring);
  });
}
