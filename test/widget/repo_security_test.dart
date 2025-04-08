import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/access_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/pages/repo_security_page.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync/ouisync.dart';

import '../utils.dart';

void main() {
  late TestDependencies deps;
  late RepoCubit repoCubit;
  late LocalSecret localSecret;

  setUp(() async {
    deps = await TestDependencies.create();

    final repoEntry = await deps.reposCubit.createRepository(
      location: RepoLocation(
        dir: (await deps.session.getStoreDir())!,
        name: 'my repo',
      ),
      setLocalSecret: randomSetLocalSecret(),
      localSecretMode: LocalSecretMode.randomStored,
    );
    repoCubit = repoEntry.cubit!;

    final authMode = repoCubit.state.authMode;

    localSecret =
        (await authMode.storedLocalSecret!.decrypt(deps.settings.masterKey))!;
  });

  tearDown(() async {
    await deps.dispose();
  });

  RepoSecurityPage createRepoSecurityPage() => RepoSecurityPage(
        deps.settings,
        deps.session,
        repoCubit,
        WriteAccess(localSecret),
        PasswordHasher(deps.session),
      );

  testWidgets(
    'set local password',
    (tester) => tester.runAsync(
      () async {
        expect(repoCubit.state.authMode, isA<AuthModeKeyStoredOnDevice>());

        await tester.pumpWidget(testApp(createRepoSecurityPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Use local password'));
        await tester.pumpAndSettle();

        final passwordField = find.byKey(Key('password'));
        final retypePasswordField = find.byKey(Key('retype-password'));

        final passwordError = find.text('Please enter a password.');
        final retypePasswordError = find.text('The passwords do not match.');

        // Initially there are no errors
        expect(passwordError, findsNothing);
        expect(retypePasswordError, findsNothing);

        // Fill in password field but not the retype password field.
        await tester.enterText(passwordField, 'admin123');
        await tester.pump();

        // Still no errors
        expect(passwordError, findsNothing);
        expect(retypePasswordError, findsNothing);

        // Start filling in the retype password field
        await tester.enterText(retypePasswordField, 'a');
        await tester.pump();

        // The retype password errors becomes visible
        expect(passwordError, findsNothing);
        expect(retypePasswordError, findsOne);

        // Clear the password field
        await tester.enterText(passwordField, '');
        await tester.pump();

        // The password error becomes visible as well
        expect(passwordError, findsOne);
        expect(retypePasswordError, findsOne);

        // Clear the retype password field
        await tester.enterText(retypePasswordField, '');
        await tester.pump();

        // Only the password error is visible
        expect(passwordError, findsOne);
        expect(retypePasswordError, findsNothing);

        // Fill both fields with the same password
        await tester.enterText(passwordField, 'admin123');
        await tester.enterText(retypePasswordField, 'admin123');
        await tester.pumpAndSettle();

        // Tap that we don't want the password to be stored.
        await tester.tap(find.descendant(
            of: find.byKey(Key('store-on-device')),
            matching: find.byType(Switch)));

        // No errors
        expect(passwordError, findsNothing);
        expect(retypePasswordError, findsNothing);

        await tester.tap(find.text('UPDATE'));
        await tester.pumpAndSettle();

        expect(
            find.text(
                'This action is irreversible, would you like to proceed?'),
            findsOne);

        await tester.tap(find.text('Accept'));
        await repoCubit.waitUntil((state) {
          return state.authMode is AuthModeBlindOrManual;
        });

        // HACK: The repo state doesn't change when the local secret changes so we can't wait
        // for it directly. But the `isLoading` switches to true before the local secret begins
        // changing and then switches back to false after it's done changing, so we can at least
        // wait for that.
        await repoCubit.waitUntil((state) => state.isLoading);
        await repoCubit.waitUntil((state) => !state.isLoading);

        await tester.pumpAndSettle();

        // Lock the repo to verify the local secret changed
        await repoCubit.lock();
        expect(repoCubit.state.accessMode, equals(AccessMode.blind));

        // Verify the old secret no longer works
        await repoCubit.unlock(localSecret);
        expect(repoCubit.state.accessMode, equals(AccessMode.blind));

        // Verify the new secret works
        await repoCubit.unlock(LocalSecretPassword(Password('admin123')));
        expect(repoCubit.state.accessMode, equals(AccessMode.write));
      },
    ),
  );
}
