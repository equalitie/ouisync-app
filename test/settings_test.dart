import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/app/utils/settings/v0.dart' as v0;
import 'package:ouisync_app/app/utils/settings/v1.dart' as v1;
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Run with `flutter test test/settings_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Settings migration', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getKeys().isEmpty, true);

    final s0 = await v0.Settings.init(prefs);

    await s0.setEqualitieValues(true);
    await s0.setShowOnboarding(false);
    await s0.setLaunchAtStartup(true);
    await s0.setSyncOnMobileEnabled(true);
    await s0.setHighestSeenProtocolNumber(1);
    await s0.addRepo(RepoLocation.fromDbPath("/foo/bar.db"),
        databaseId: "123", authenticationMode: AuthMode.manual);
    await s0.setDefaultRepo("bar");

    final s1 = await loadAndMigrateSettings();

    await prefs.reload();

    // In version 1 we only expect the `SETTINGS_VERSION_KEY` and
    // `SETTINGS_VERSION` values to be present.
    expect(prefs.getKeys().length, 2);

    expect(s1.repos().length, 1);

    s1.addRepo(RepoLocation.fromDbPath("/foo/baz.db"),
        databaseId: DatabaseId("234"), authenticationMode: AuthMode.manual);

    expect(s1.repos().length, 2);
  });
}
