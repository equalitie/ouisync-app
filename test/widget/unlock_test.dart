import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/models/repo_entry.dart';
import 'package:ouisync_app/app/pages/repo_security_page.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/app/widgets/buttons/elevated_async_button.dart';
import 'package:ouisync_app/app/widgets/repo_security.dart';
import 'package:ouisync_app/app/widgets/items/entry_action_item.dart'
    show EntryActionItem;
import 'package:ouisync/ouisync.dart';

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

  Future<RepoCubit> createAndEnterRepository(WidgetTester tester) async {
    final repoCreationObserver = StateObserver.install<RepoCreationState>();

    await tester.pumpWidget(testApp(deps.createMainPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CREATE REPOSITORY'));
    await tester.pumpAndSettle();

    // Filling in the repo name triggers an async operation and so we must explicitly wait until
    // it completes.
    await tester.enterText(find.byKey(ValueKey('name')), 'my repo');
    await repoCreationObserver
        .waitUntil((state) => state.substate is RepoCreationValid);
    await tester.pump();

    await tester.tap(find.descendant(
      of: find.byKey(ValueKey('use-cache-servers')),
      matching: find.byType(Switch),
    ));
    await tester.pump();

    // Verify that use cache servers is off:
    await repoCreationObserver.waitUntil((state) => !state.useCacheServers);

    await tester.tap(find.text('CREATE'));

    await repoCreationObserver
        .waitUntil((state) => state.substate is RepoCreationSuccess);

    final repoCubit = deps.reposCubit.repos
        .where((entry) => entry.name == 'my repo')
        .first
        .cubit!;

    expect(repoCubit.state.accessMode, equals(AccessMode.write));
    expect(repoCubit.state.isCacheServersEnabled, isFalse);

    return repoCubit;
  }

  Future<void> enterRepoSettings(WidgetTester tester) async {
    final repoSettingsIcon = Icons.more_vert_rounded; // The three vertical dots

    await tester.tap(await tester
        .pumpUntilFound(find.widgetWithIcon(IconButton, repoSettingsIcon)));
  }

  Future<void> tapSecurityButton(WidgetTester tester) async {
    final findSecurityButton =
        find.widgetWithIcon(EntryActionItem, Icons.password_outlined);
    final found = await tester.pumpUntilFound(findSecurityButton);

    await tester.tap(found);
    await tester.pumpAndSettle();
  }

  Future<void> tapButton(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> enterRepoResetScreen(WidgetTester tester) async {
    await tester.tap(await tester
        .pumpUntilFound(find.byKey(Key('enter-repo-reset-screen'))));
    await tester.pumpAndSettle();
  }

  Future<void> enterTokenInRepoResetScreen(
      WidgetTester tester, ShareToken token) async {
    await tester.enterText(find.byKey(Key('token-input')), token.toString());
    await tester.pumpAndSettle();
  }

  Future<void> tapUseLocalPasswordSwitchInSecurityScreen(
      WidgetTester tester) async {
    await tester.tap(find.descendant(
      of: find.byKey(Key('use-local-password')),
      matching: find.byType(Switch),
    ));
    await tester.pumpAndSettle();
  }

  bool getSecurityScreenStoreOnDeviceValue(WidgetTester tester) {
    return tester
        .widget<Switch>(find.descendant(
            of: find.byKey(Key('store-on-device')),
            matching: find.byType(Switch)))
        .value;
  }

  Future<void> enterPasswordsInSecurityScreen(
      WidgetTester tester, String password) async {
    await tester.enterText(find.byKey(Key('password')), password);
    await tester.enterText(find.byKey(Key('retype-password')), password);
    await tester.pumpAndSettle();
  }

  Future<void> awaitFoundThenTap(WidgetTester tester, Finder finder) async {
    await tester.tap(await tester.pumpUntilFound(finder));
    await tester.pumpAndSettle();
  }

  // Silly dialog that mimics the biometric test by asking if it's "me".
  Future<void> confirmMockBiometricTest(WidgetTester tester) async {
    if (await LocalAuth.canAuthenticate()) {
      await tapButton(tester, 'Yes');
      await tester.pumpAndSettle();
    }
  }

  Future<void> hideSnackBarFrom(WidgetTester tester, Finder finder) async {
    ScaffoldMessenger.of(finder.evaluate().single).clearSnackBars();
    await tester.pumpAndSettle();
  }

  //------------------------------------------------------------------

  testWidgets(
    'go to repo security while unlocked',
    (tester) => tester.runAsync(
      () async {
        // Uncomment when debugging.
        //await tester.loadFonts();

        final repoCubit = await createAndEnterRepository(tester);

        final blindToken = await repoCubit.createShareToken(AccessMode.blind);
        final readToken = await repoCubit.createShareToken(AccessMode.read);
        final writeToken = await repoCubit.createShareToken(AccessMode.write);

        await enterRepoSettings(tester);
        await tapSecurityButton(tester);
        await confirmMockBiometricTest(tester);
        await enterRepoResetScreen(tester);

        await enterTokenInRepoResetScreen(tester, blindToken);
        await awaitFoundThenTap(tester, find.text('Submit'));
        await awaitFoundThenTap(tester, find.text('Done'));

        await tapButton(tester, 'UNLOCK');
        await enterRepoResetScreen(tester);

        await enterTokenInRepoResetScreen(tester, readToken);
        await awaitFoundThenTap(tester, find.text('Submit'));
        await awaitFoundThenTap(tester, find.text('Done'));

        await enterRepoSettings(tester);
        await tapSecurityButton(tester);
        await confirmMockBiometricTest(tester);

        await tapUseLocalPasswordSwitchInSecurityScreen(tester);

        final password = 'password';

        final isStored = getSecurityScreenStoreOnDeviceValue(tester);

        expect(isStored, true,
            reason:
                'The current default reset access code resets the secret with the "store" option set to `true`, so it should be preserved here');

        await enterPasswordsInSecurityScreen(tester, password);

        final updateButtonFinder = find.byKey(Key('security-update-button'));
        final updateButtonState =
            tester.state<ElevatedAsyncButtonState>(updateButtonFinder);

        await hideSnackBarFrom(tester, updateButtonFinder);
        await tester.tap(updateButtonFinder);
        await tester.pumpAndSettle();

        // Dialog to confirm.
        await tapButton(tester, 'Accept');

        expect(updateButtonState.isExecuting, true);
        await tester.pumpUntil(() {
          return updateButtonState.isExecuting == false;
        });

        final repoSecurityWidget =
            tester.widget<RepoSecurity>(find.byType(RepoSecurity));

        expect(repoSecurityWidget.cubit.state.hasPendingChanges, false);
      },
    ),
  );

  testWidgets(
    'reset to blind even if locked',
    (tester) => tester.runAsync(
      () async {
        // Uncomment when debugging.
        //await tester.loadFonts();

        final repoCubit = await createAndEnterRepository(tester);

        final blindToken = await repoCubit.createShareToken(AccessMode.blind);
        final writeToken = await repoCubit.createShareToken(AccessMode.write);

        // The repo is in write mode, tapping this button will lock it.
        await awaitFoundThenTap(tester, find.byKey(Key('access-mode-button')));

        await enterRepoSettings(tester);
        await tapSecurityButton(tester);
        await confirmMockBiometricTest(tester);
        await enterRepoResetScreen(tester);

        await enterTokenInRepoResetScreen(tester, blindToken);

        // Check that we can still submit a blind token even if the repository
        // is locked (i.e. appearing as already blind).
        await awaitFoundThenTap(tester, find.text('Submit'));
        await awaitFoundThenTap(tester, find.text('Done'));
      },
    ),
  );
}
