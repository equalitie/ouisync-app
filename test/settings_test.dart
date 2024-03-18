import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/app/utils/settings/v0/v0.dart' as v0;
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Run with `flutter test test/settings_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Settings migration', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getKeys().isEmpty, true);

    final s0 = await v0.Settings.init(prefs);

    await s0.setEqualitieValues(true);
    await s0.setShowOnboarding(false);
    await s0.setLaunchAtStartup(true);
    await s0.setSyncOnMobileEnabled(true);
    await s0.setHighestSeenProtocolNumber(1);
    await s0.addRepo(
      RepoLocation.fromDbPath("/foo/bar.db"),
      databaseId: "123",
      authenticationMode: v0.AuthMode.manual,
    );
    await s0.setDefaultRepo("bar");

    final s1 = await loadAndMigrateSettings();

    await prefs.reload();

    // In version 1 we only expect the `SETTINGS_KEY` value to be present.
    expect(prefs.getKeys().length, 1);

    expect(s1.repos.length, 1);

    await s1.setRepoLocation(
      DatabaseId("234"),
      RepoLocation.fromDbPath("/foo/baz.db"),
    );

    expect(s1.repos.length, 2);
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
    //  print("key: $rawKey");
    //  final key = MasterKey.initWithKey(rawKey);
    //  final encrypted = await key.encrypt(teststring);
    //  print("encrypted: $encrypted");
    //}

    final key =
        MasterKey.initWithKey("eZcpF/CdFblXXhFP4LHk49lGtDEY4c1Gn/qQKBU0QmA=");

    final encrypted = "cKMbibnjHsni8olld2sUXjxNsAroR/DOKNj3rUOOrFtUrA==";

    expect(await key.decrypt(encrypted), teststring);
  });
}
