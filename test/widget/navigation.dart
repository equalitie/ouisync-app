import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/models/repo_entry.dart';
import 'package:ouisync_app/app/pages/repo_security_page.dart';
import 'package:ouisync_app/app/pages/repo_reset_access.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/app/widgets/buttons/elevated_async_button.dart';
import 'package:ouisync_app/app/widgets/items/entry_action_item.dart'
    show EntryActionItem;
import 'package:ouisync/ouisync.dart';
import '../utils.dart';

//--------------------------------------------------------------------

class MainPage {
  final WidgetTester tester;
  final TestDependencies deps;

  MainPage(this.tester, this.deps);

  Future<RepoPage> createAndEnterRepository() async {
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

    return RepoPage(tester, repoCubit);
  }
}

//--------------------------------------------------------------------

class RepoPage {
  final WidgetTester tester;
  final RepoCubit repoCubit;

  RepoPage(this.tester, this.repoCubit);

  Future<ShareToken> createBlindToken() async {
    return await repoCubit.createShareToken(AccessMode.blind);
  }

  Future<ShareToken> createReadToken() async {
    return await repoCubit.createShareToken(AccessMode.read);
  }

  Future<ShareToken> createWriteToken() async {
    return await repoCubit.createShareToken(AccessMode.write);
  }

  Future<RepoSettings> enterRepoSettings() async {
    final repoSettingsIcon = Icons.more_vert_rounded; // The three vertical dots

    await tester.tap(await tester
        .pumpUntilFound(find.widgetWithIcon(IconButton, repoSettingsIcon)));

    return RepoSettings(tester);
  }

  // This is the button that shows which mode the repository is in. If it's in
  // read or write mode, clicking it will lock the repository.
  Future<void> tapAccessModeButton() async {
    await tester.tap(
        await tester.pumpUntilFound(find.byKey(Key('access-mode-button'))));
    await tester.pumpAndSettle();
  }

  Future<void> tapUnlockButton() async {
    await tester.tap(find.text('UNLOCK'));
    await tester.pumpAndSettle();
  }
}

//--------------------------------------------------------------------

class RepoSettings {
  final WidgetTester tester;

  RepoSettings(this.tester);

  Future<void> tapSecurityButton() async {
    final findSecurityButton =
        find.widgetWithIcon(EntryActionItem, Icons.password_outlined);
    final found = await tester.pumpUntilFound(findSecurityButton);

    await tester.tap(found);
    await tester.pumpAndSettle();
  }

  Future<SecurityPage> enterSecurityPage() async {
    await tapSecurityButton();
    await MockAuthDialog.confirm(tester);
    await tester.pumpUntilFound(find.byType(RepoSecurityPage));
    await tester.pumpAndSettle();
    return SecurityPage(tester);
  }
}

//--------------------------------------------------------------------

class SecurityPage {
  final WidgetTester tester;
  SecurityPage(this.tester);

  Future<RepoResetPage> enterRepoResetPage() async {
    await tester.tap(await tester
        .pumpUntilFound(find.byKey(Key('enter-repo-reset-screen'))));
    await tester.pumpUntilFound(find.byType(RepoResetAccessPage));
    await tester.pumpAndSettle();
    return RepoResetPage(tester);
  }

  Future<void> tapUseLocalPasswordSwitch() async {
    await tester.tap(find.descendant(
      of: find.byKey(Key('use-local-password')),
      matching: find.byType(Switch),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tapRememberPasswordSwitch() async {
    await tester.tap(find.descendant(
      of: find.byKey(Key('store-on-device')),
      matching: find.byType(Switch),
    ));
    await tester.pumpAndSettle();
  }

  bool getRememberPasswordValue() {
    return tester
        .widget<Switch>(find.descendant(
            of: find.byKey(Key('store-on-device')),
            matching: find.byType(Switch)))
        .value;
  }

  Future<void> enterPasswords(String password) async {
    await tester.enterText(find.byKey(Key('password')), password);
    await tester.enterText(find.byKey(Key('retype-password')), password);
    await tester.pumpAndSettle();
  }

  Future<void> submit() async {
    final updateButtonFinder = find.byKey(Key('security-update-button'));
    final updateButtonState =
        tester.state<ElevatedAsyncButtonState>(updateButtonFinder);

    // Hide the snackbar so we can tap on it.
    ScaffoldMessenger.of(updateButtonFinder.evaluate().single).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(updateButtonFinder);
    await tester.pumpAndSettle();

    // Dialog to confirm.
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    // Wait for the update to finish.
    expect(updateButtonState.isExecuting, true);
    await tester.pumpUntil(() {
      return updateButtonState.isExecuting == false;
    });

    // Ensure that after the submission the user may exit the page without
    // being prompted to discard pending changes.
    final repoSecurityWidget =
        tester.widget<RepoSecurityWidget>(find.byType(RepoSecurityWidget));

    expect(repoSecurityWidget.cubit.state.hasPendingChanges, false,
        reason: "There should be no more pending changes");
  }
}

//--------------------------------------------------------------------

class RepoResetPage {
  final WidgetTester tester;
  RepoResetPage(this.tester);

  Future<void> enterToken(ShareToken token) async {
    await tester.enterText(find.byKey(Key('token-input')), token.toString());
    await tester.pumpAndSettle();
  }

  Future<void> submit() async {
    // TODO: Check that the button is enabled.

    await tester
        .tap(await tester.pumpUntilFound(find.byKey(Key('repo-reset-submit'))));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();

    // Await until finished submitting/updating.
    final accessResetPage = tester
        .state<RepoResetAccessPageState>(find.byType(RepoResetAccessPage));

    await tester.pumpUntil(() => accessResetPage.hasPendingChanges == false);
  }
}

//--------------------------------------------------------------------

class MockAuthDialog {
  // Silly dialog that mimics the biometric test by asking if it's "me".
  static Future<void> confirm(WidgetTester tester) async {
    if (await LocalAuth.canAuthenticate()) {
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
    }
  }
}

//--------------------------------------------------------------------

class UnlockDialog {
  static Future<RepoResetPage> enterRepoResetPage(WidgetTester tester) async {
    await tester.tap(await tester
        .pumpUntilFound(find.byKey(Key('enter-repo-reset-screen'))));
    await tester.pumpAndSettle();

    await MockAuthDialog.confirm(tester);

    await tester.pumpUntilFound(find.byType(RepoResetAccessPage));
    await tester.pumpAndSettle();

    return RepoResetPage(tester);
  }
}
