import 'package:flutter_test/flutter_test.dart';
import 'navigation.dart';
import '../utils.dart';

void main() {
  late TestDependencies deps;

  setUp(() async {
    deps = await TestDependencies.create();
  });

  tearDown(() async {
    await deps.dispose();
  });

  //------------------------------------------------------------------

  testWidgets(
    'go to repo security while unlocked',
    (tester) => tester.runAsync(
      () async {
        // Uncomment when debugging.
        //await tester.loadFonts();

        final mainPage = MainPage(tester, deps);

        // Create repo
        final repoPage = await mainPage.createAndEnterRepository();

        final blindToken = await repoPage.createBlindToken();
        final readToken = await repoPage.createReadToken();

        final repoSettings = await repoPage.enterRepoSettings();
        final repoSecurity = await repoSettings.enterSecurityPage();
        final repoReset = await repoSecurity.enterRepoResetPage();

        await repoReset.enterToken(blindToken);
        await repoReset.submit();

        await tester.pageBack();
        await tester.pumpAndSettle();

        await repoPage.tapUnlockButton();
        await UnlockDialog.enterRepoResetPage(tester);

        await repoReset.enterToken(readToken);
        await repoReset.submit();

        await tester.pageBack();
        await tester.pumpAndSettle();

        await repoPage.enterRepoSettings();
        await repoSettings.enterSecurityPage();

        await repoSecurity.tapUseLocalPasswordSwitch();

        final isStored = repoSecurity.getSecretIsStoredOnDeviceValue();

        expect(isStored, true,
            reason:
                'The current default reset access code resets the secret with the "store" option set to `true`, so it should be preserved here');

        await repoSecurity.enterPasswords('password');
        await repoSecurity.submit();
      },
    ),
  );

  testWidgets(
    'reset to blind even if locked',
    (tester) => tester.runAsync(
      () async {
        // Uncomment when debugging.
        //await tester.loadFonts();

        final mainPage = MainPage(tester, deps);
        final repoPage = await mainPage.createAndEnterRepository();

        final blindToken = await repoPage.createBlindToken();
        final writeToken = await repoPage.createWriteToken();

        // The repo is in write mode, tapping this button will lock it.
        await repoPage.tapAccessModeButton();

        final repoSettings = await repoPage.enterRepoSettings();
        final repoSecurity = await repoSettings.enterSecurityPage();
        final repoReset = await repoSecurity.enterRepoResetPage();

        // Check that we can still submit a blind token even if the repository
        // is locked (i.e. appearing as already blind).
        await repoReset.enterToken(blindToken);
        await repoReset.submit();
      },
    ),
  );
}
