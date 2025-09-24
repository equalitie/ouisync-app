import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/utils/storage.dart' show Storage;

import '../test/sandbox.dart';
import '../test/utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Sandbox? sandbox;
  var appController = AppController();

  Future<void> init(WidgetTester tester) async {
    await tester.pumpWidget(App.test(controller: appController));
    await tester.pumpAndSettle();
  }

  setUp(() async {
    sandbox = await Sandbox.setUp();
    appController = AppController();
  });

  tearDown(() async {
    // Stop the ouisync service so the next test can start with a clean slate.
    await appController.stop();
    appController.dispose();

    await sandbox?.tearDown();
    sandbox = null;
  });

  testWidgets('sanity check', (tester) async {
    await init(tester);
    await onboard(tester);
  });

  testWidgets('rename repo', (tester) async {
    final oldName = 'Cat pictures';
    final newName = 'Funny pictures';

    // Create a repo
    await init(tester);
    await onboard(tester);
    await createRepo(tester, name: oldName);

    // Open the rename dialog and rename the repo
    final settingButton = find.repoSettingsButton();
    await tester.pumpUntilFound(settingButton);

    await tester.tap(settingButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(ValueKey('new-name')), newName);
    await tester.pumpAndSettle();

    await tester.tap(find.text('RENAME'));
    await tester.pumpAndSettle();

    // Verify snackbar message
    expect(find.text('Repository renamed as $newName'), findsOne);
    // Verify the new name appears in the title bar
    expect(
      find.descendant(
        of: find.bySubtype<AppBar>(),
        matching: find.text(newName),
      ),
      findsOne,
    );
    expect(find.text(oldName), findsNothing);

    // Go back to the repo list page
    await tester.tap(find.backButton());
    await tester.pumpAndSettle();

    // Verify the repo has the new name in the list
    expect(find.text(newName), findsOne);
    expect(find.text(oldName), findsNothing);
  });

  testWidgets('create repo on removable storage', (tester) async {
    await init(tester);
    await onboard(tester);

    // Create the repo on the removable storage (sdcard)
    await tester.tap(find.text('CREATE REPOSITORY'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(ValueKey('name')), 'my repo');
    await tester.pumpAndSettle();

    // Find the radio tile with the "sd_card" icon which should correspond to the removable
    // storage.
    final removable = find.widgetWithIcon(RadioListTile<String>, Icons.sd_card);
    expect(removable, isNot(isChecked));

    // Verify the storage really is removable.
    final removableStorage = await Storage.forPath(
      tester.firstWidget<RadioListTile<String>>(removable).value,
    ).then((storage) => storage!);
    expect(removableStorage.removable, isTrue);

    await tester.tap(removable);
    await tester.pumpAndSettle();

    expect(removable, isChecked);

    await tester.tap(find.text('CREATE'));
    await tester.pumpAndSettle();

    // Open the repo settings
    final settingButton = find.repoSettingsButton();
    await tester.pumpUntilFound(settingButton);
    await tester.tap(settingButton);
    await tester.pumpAndSettle();

    // Verify the storage settings tile shows the removable storage.
    final storageTile = find.widgetWithText(ListTile, 'Storage');
    expect(
      find.descendant(
        of: storageTile,
        matching: find.text(removableStorage.description),
      ),
      findsOne,
    );

    // Open the storage dialog
    await tester.tap(storageTile);
    await tester.pumpAndSettle();

    expect(removable, isChecked);

    // Find the radio tile with the "smartphone" icon which should correspond to the internal
    // storage.
    final internal = find.widgetWithIcon(
      RadioListTile<String>,
      Icons.smartphone,
    );
    expect(internal, isNot(isChecked));

    // Verify the storage is really internal (not removable)
    final internalStorage = await Storage.forPath(
      tester.firstWidget<RadioListTile<String>>(internal).value,
    ).then((storage) => storage!);
    expect(internalStorage.removable, isFalse);

    // Select it and confirm the move.
    await tester.tap(internal);
    await tester.pumpAndSettle();

    await tester.tap(find.text('MOVE'));
    await tester.pumpAndSettle();

    expect(removable, isNot(isChecked));
    expect(internal, isChecked);

    // Close the storage dialog
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();

    // Verify the storage tile now shows the internal storage.
    expect(
      find.descendant(
        of: storageTile,
        matching: find.text(internalStorage.description),
      ),
      findsOne,
    );
  }, tags: ['removable-storage']);
}

Future<void> onboard(WidgetTester tester) async {
  await tester.tap(find.text('English').first);
  await tester.pumpAndSettle();

  for (var i = 0; i < 3; ++i) {
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
  }

  await tester.tap(find.text('I AGREE'));
  await tester.pumpAndSettle();
}

Future<void> createRepo(WidgetTester tester, {required String name}) async {
  await tester.tap(find.text('CREATE REPOSITORY'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(ValueKey('name')), name);
  await tester.pumpAndSettle();

  await tester.tap(find.text('CREATE'));
  await tester.pumpAndSettle();
}

extension on CommonFinders {
  Finder repoSettingsButton() => descendant(
    of: find.bySubtype<AppBar>(),
    matching: find.byIcon(Icons.more_vert_rounded),
  );
}

class _IsChecked extends Matcher {
  @override
  bool matches(covariant FinderBase<Element> item, Map matchState) =>
      switch (item.evaluate().single.widget) {
        RadioListTile(value: final value, groupValue: final groupValue) =>
          value == groupValue,
        _ => false,
      };

  @override
  Description describe(Description description) => description.add('checked');
}

final isChecked = _IsChecked();
