import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/pages/repo_security_page.dart';
import 'package:ouisync_app/app/pages/repo_reset_access.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/app/widgets/buttons/elevated_async_button.dart';
import 'package:ouisync_app/app/widgets/dialogs/modal_actions_bottom_sheet.dart'
    show DirectoryActions;
import 'package:ouisync_app/app/widgets/items/entry_action_item.dart'
    show EntryActionItem;
import 'package:ouisync/ouisync.dart';
import 'utils.dart';
import 'fake_file_picker.dart';

//--------------------------------------------------------------------

class MainPage {
  final WidgetTester tester;
  final TestDependencies deps;

  MainPage(this.tester, this.deps);

  Future<RepoPage> createAndEnterRepository() async {
    final repoCreationObserver = StateObserver.install<RepoCreationState>();

    await tester.pumpWidget(testApp(deps.createMainPage()));
    await tester.pumpAndSettle();

    await tester.anxiousTap(
      await tester.pumpUntilFound(find.byKey(Key('create_first_repo'))),
    );
    await tester.pumpAndSettle();

    // Filling in the repo name triggers an async operation and so we must explicitly wait until
    // it completes.
    await tester.enterText(find.byKey(ValueKey('name')), 'my repo');
    await repoCreationObserver.waitUntil(
      (state) => state.substate is RepoCreationValid,
    );
    await tester.pump();

    // Not using `anxiousTap` because it's a switch.
    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey('use-cache-servers')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump();

    // Verify that use cache servers is off:
    await repoCreationObserver.waitUntil((state) => !state.useCacheServers);

    await tester.anxiousTap(find.byKey(Key('create-repository')));

    await repoCreationObserver.waitUntil(
      (state) => state.substate is RepoCreationSuccess,
    );

    final repoCubit = deps.reposCubit.state.repos.values
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

    final button = await tester.pumpUntilFound(
      find.widgetWithIcon(IconButton, repoSettingsIcon),
    );

    await tester.anxiousTap(button);

    return RepoSettings(tester);
  }

  // Tap the `+` button for adding files or folders to a repo and add the file at `filePath`.
  Future<void> addFile(String filePath) async {
    final fab = await tester.pumpUntilFound(find.byType(FloatingActionButton));
    await tester.anxiousTap(fab);
    await tester.pumpAndSettle();

    fakeFilePickerPicks(filePath);

    await tester.anxiousTap(
      await tester.pumpUntilFound(
        find.descendant(
          of: find.byType(DirectoryActions),
          matching: find.byKey(Key('add_file_action')),
        ),
      ),
    );

    // Wait to get back to the repo screen
    await tester.pumpUntilNotFound(find.byType(DirectoryActions));
  }

  // Create folder `folderName` in the current repo/folder. On success, the app
  // will end up that folder.
  Future<void> addFolder(String folderName) async {
    final fab = await tester.pumpUntilFound(find.byType(FloatingActionButton));
    await tester.anxiousTap(fab);
    await tester.pumpAndSettle();

    await tester.anxiousTap(
      await tester.pumpUntilFound(
        find.descendant(
          of: find.byType(DirectoryActions),
          matching: find.byKey(Key('add_folder_action')),
        ),
      ),
    );

    final findNameInput = find.byKey(Key('create_folder_name_input'));
    final nameInput = await tester.pumpUntilFound(findNameInput);
    await tester.enterText(nameInput, folderName);

    await tester.anxiousTap(find.byKey(Key('create_folder_submit')));

    // Wait for the dialog and bottom sheet to disappear.
    await tester.pumpUntilNotFound(find.byType(DirectoryActions));
  }

  Finder findDirEntry(String name) {
    return find.descendant(
      of: find.byKey(Key('directory_entry_list')),
      matching: find.byKey(Key(name)),
    );
  }

  Future<void> tapFolder(String folderName) async {
    final dirEntry = await tester.pumpUntilFound(findDirEntry(folderName));
    expect(dirEntry, findsOneWidget);
    await tester.anxiousTap(dirEntry);
  }

  Future<void> tapBackButton() async {
    final appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);

    final findBackButton = find.descendant(
      of: appBar,
      matching: find.byIcon(Icons.arrow_back),
    );
    final backButton = await tester.pumpUntilFound(findBackButton);
    await tester.anxiousTap(backButton);
  }

  Future<void> tapEntryActions(String entryName) async {
    final entry = await tester.pumpUntilFound(find.byKey(Key(entryName)));
    final actions = find.descendant(
      of: entry,
      matching: find.byKey(Key('file_vert')),
    );
    await tester.anxiousTap(actions);
  }

  // This is the button that shows which mode the repository is in. If it's in
  // read or write mode, clicking it will lock the repository.
  Future<void> tapAccessModeButton() async {
    await tester.tap(
      await tester.pumpUntilFound(find.byKey(Key('access-mode-button'))),
    );
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
    final findSecurityButton = find.widgetWithIcon(
      EntryActionItem,
      Icons.password_outlined,
    );
    final found = await tester.pumpUntilFound(findSecurityButton);

    // Not `anxiousTap` because tapping again will remove the `MockAuthDialog`.
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
    await tester.anxiousTap(
      await tester.pumpUntilFound(find.byKey(Key('enter-repo-reset-screen'))),
    );
    await tester.pumpUntilFound(find.byType(RepoResetAccessPage));
    await tester.pumpAndSettle();
    return RepoResetPage(tester);
  }

  Future<void> tapUseLocalPasswordSwitch() async {
    // Not using `anxiousTap` because repeated tapping switches the state back
    // and forth.
    await tester.tap(
      find.descendant(
        of: find.byKey(Key('use-local-password')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapRememberPasswordSwitch() async {
    // Not using `anxiousTap` because the state would switch back and forth.
    await tester.tap(
      find.descendant(
        of: find.byKey(Key('store-on-device')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool getRememberPasswordValue() {
    return tester
        .widget<Switch>(
          find.descendant(
            of: find.byKey(Key('store-on-device')),
            matching: find.byType(Switch),
          ),
        )
        .value;
  }

  Future<void> enterPasswords(String password) async {
    await tester.enterText(find.byKey(Key('password')), password);
    await tester.enterText(find.byKey(Key('retype-password')), password);
    await tester.pumpAndSettle();
  }

  Future<void> submit() async {
    final updateButtonFinder = find.byKey(Key('security-update-button'));
    final updateButtonState = tester.state<ElevatedAsyncButtonState>(
      updateButtonFinder,
    );

    final oldExecCount = updateButtonState.execCounter;

    // Hide the snackbar so we can tap on it.
    ScaffoldMessenger.of(updateButtonFinder.evaluate().single).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(updateButtonFinder);
    await tester.pumpAndSettle();

    // Dialog to confirm.
    await tester.anxiousTap(find.text('Accept'));
    await tester.pumpAndSettle();

    // Wait for the update to finish.
    await tester.pumpUntil(() {
      return updateButtonState.execCounter == oldExecCount + 1;
    });

    // Ensure that after the submission the user may exit the page without
    // being prompted to discard pending changes.
    final repoSecurityWidget = tester.widget<RepoSecurityWidget>(
      find.byType(RepoSecurityWidget),
    );

    expect(
      repoSecurityWidget.cubit.state.hasPendingChanges,
      false,
      reason: "There should be no more pending changes",
    );
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
    final submitButton = await tester.pumpUntilFound(
      timeout: Duration(seconds: 30),
      find.byKey(Key('repo-reset-submit')),
    );

    // Wait for the button to become enabled
    await tester.pumpUntil(() {
      final state = tester.state(submitButton) as ElevatedAsyncButtonState;
      return state.widget.onPressed != null;
    });

    // Non `anxiousTap` because tapping again will remove the confirmation dialog.
    await tester.tap(submitButton);

    // Confirm
    await tester.anxiousTap(await tester.pumpUntilFound(find.text('YES')));
    await tester.pumpAndSettle();

    // Await until finished submitting/updating.
    final accessResetPage = tester.state<RepoResetAccessPageState>(
      find.byType(RepoResetAccessPage),
    );

    await tester.pumpUntil(() => accessResetPage.hasPendingChanges == false);
  }
}

//--------------------------------------------------------------------

class MockAuthDialog {
  // Silly dialog that mimics the biometric test by asking if it's "me".
  static Future<void> confirm(WidgetTester tester) async {
    try {
      if (await LocalAuth.canAuthenticate()) {
        await tester.anxiousTap(find.text('Yes'));
        await tester.pumpAndSettle();
      }
    } catch (e) {
      await tester.takeScreenshot("MockAuthDialog_confirm");
      rethrow;
    }
  }
}

//--------------------------------------------------------------------

class UnlockDialog {
  static Future<RepoResetPage> enterRepoResetPage(WidgetTester tester) async {
    await tester.anxiousTap(
      await tester.pumpUntilFound(find.byKey(Key('enter-repo-reset-screen'))),
    );
    await tester.pumpAndSettle();

    await MockAuthDialog.confirm(tester);

    await tester.pumpUntilFound(find.byType(RepoResetAccessPage));
    await tester.pumpAndSettle();

    return RepoResetPage(tester);
  }
}
