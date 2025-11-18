import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/cubits/store_dirs.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_app/app/utils/storage_volume.dart' show StorageVolume;
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectories;

import '../test/sandbox.dart';
import '../test/utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Sandbox? sandbox;
  var appController = AppController();

  Future<void> init(WidgetTester tester, {bool skipOnboarding = false}) async {
    if (skipOnboarding) {
      final settings = await Settings.init(MasterKey.random());
      await settings.setShowOnboarding(false);
      await settings.setEqualitieValues(true);
    }

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

  // -----------------------------------------------------------------------------------------------

  testWidgets('sanity check', (tester) async {
    await init(tester);
    await onboard(tester);
  });

  // -----------------------------------------------------------------------------------------------

  testWidgets('rename repo', (tester) async {
    final oldName = 'Cat pictures';
    final newName = 'Funny pictures';

    // Create a repo
    await init(tester, skipOnboarding: true);
    await createRepo(tester, name: oldName);

    // Open the rename dialog and rename the repo
    await openRepoSettings(tester);

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

  // -----------------------------------------------------------------------------------------------

  testWidgets('create repo on removable storage', (tester) async {
    await requireRemovableStorage();

    await init(tester, skipOnboarding: true);

    // Create the repo on the removable storage (sdcard)
    await goToCreateRepoPage(tester);
    await enterRepoName(tester, 'my repo');

    // Find the radio tile with the "sd_card" icon which should correspond to the removable
    // storage.
    final removable = find.removableStorageRadio();
    expect(removable, isNot(isChecked));

    // Verify the storage really is removable.
    final removableDir = tester
        .firstWidget<RadioListTile<StoreDir>>(removable)
        .value;
    expect(removableDir.volume.isRemovable, isTrue);

    await tester.tap(removable);
    await tester.pumpAndSettle();

    expect(removable, isChecked);

    await tapCreateButton(tester);

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
        matching: find.text(removableDir.volume.description),
      ),
      findsOne,
    );

    // Open the storage dialog
    await tester.tap(storageTile);
    await tester.pumpAndSettle();

    expect(removable, isChecked);

    // Find the radio tile with the "smartphone" icon which should correspond to the internal
    // storage.
    final internal = find.internalStorageRadio();
    expect(internal, isNot(isChecked));

    // Verify the storage is really internal (not removable)
    final internalDir = tester
        .firstWidget<RadioListTile<StoreDir>>(internal)
        .value;
    expect(internalDir.volume.isRemovable, isFalse);

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
        matching: find.text(internalDir.volume.description),
      ),
      findsOne,
    );
  }, tags: ['removable-storage']);

  // -----------------------------------------------------------------------------------------------

  testWidgets('move repo to removable storage then delete it', (tester) async {
    await requireRemovableStorage();

    await init(tester, skipOnboarding: true);

    await createRepo(tester, name: 'my repo', storage: Storage.internal);
    await openRepoSettings(tester);
    await moveRepoToStorage(tester, Storage.removable);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    // Verify snackbar message
    expect(find.text('Repository my repo deleted'), findsOne);

    // Verify the repo is gone
    expect(find.text('my repo'), findsNothing);
  }, tags: ['removable-storage']);
}

// Precondition: check there is at least one removable storage volume
Future<void> requireRemovableStorage() async {
  final volumes = await getExternalStorageDirectories().then(
    (dirs) =>
        Future.wait(dirs?.map((dir) => StorageVolume.forPath(dir.path)) ?? []),
  );

  expect(volumes.length, greaterThan(1));
  expect(
    volumes,
    contains(
      isA<StorageVolume>().having(
        (volume) => volume.isRemovable,
        "removable",
        isTrue,
      ),
    ),
  );
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

enum Storage { internal, removable }

Future<void> createRepo(
  WidgetTester tester, {
  required String name,
  Storage storage = Storage.internal,
}) async {
  await goToCreateRepoPage(tester);
  await enterRepoName(tester, name);

  switch (storage) {
    case Storage.internal:
      break;
    case Storage.removable:
      await selectRemovableStorage(tester);
  }

  await tapCreateButton(tester);
}

Future<void> goToCreateRepoPage(WidgetTester tester) async {
  await tester.tap(find.text('CREATE REPOSITORY'));
  await tester.pumpAndSettle();
}

Future<void> enterRepoName(WidgetTester tester, String name) async {
  await tester.enterText(find.byKey(ValueKey('name')), name);
  await tester.pumpAndSettle();
}

Future<void> selectRemovableStorage(WidgetTester tester) async {
  await tester.tap(find.removableStorageRadio());
  await tester.pumpAndSettle();
}

Future<void> tapCreateButton(WidgetTester tester) async {
  final createButton = find.text('CREATE');
  await tester.ensureVisible(createButton);
  await tester.tap(createButton);
  await tester.pumpAndSettle();
}

Future<void> openRepoSettings(WidgetTester tester) async {
  final settingButton = find.repoSettingsButton();
  await tester.pumpUntilFound(settingButton);

  await tester.tap(settingButton);
  await tester.pumpAndSettle();
}

Future<void> moveRepoToStorage(WidgetTester tester, Storage dst) async {
  // Open the storage dialog
  final storageTile = find.widgetWithText(ListTile, 'Storage');
  await tester.tap(storageTile);
  await tester.pumpAndSettle();

  // Check the corresponding radio button
  final radio = switch (dst) {
    Storage.internal => find.internalStorageRadio(),
    Storage.removable => find.removableStorageRadio(),
  };

  await tester.tap(radio);
  await tester.pumpAndSettle();

  // Confirm the move
  await tester.tap(find.text('MOVE'));
  await tester.pumpAndSettle();

  // Close the storage dialog
  await tester.tap(find.text('CLOSE'));
  await tester.pumpAndSettle();
}

extension on CommonFinders {
  Finder repoSettingsButton() => descendant(
    of: find.bySubtype<AppBar>(),
    matching: find.byIcon(Icons.more_vert_rounded),
  );

  Finder removableStorageRadio() =>
      find.widgetWithIcon(RadioListTile<StoreDir>, Icons.sd_card);

  Finder internalStorageRadio() =>
      find.widgetWithIcon(RadioListTile<StoreDir>, Icons.smartphone);
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
