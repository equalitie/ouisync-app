import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ouisync_app/app/app.dart';

import '../test/sandbox.dart';
import '../test/utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Sandbox? sandbox;

  setUp(() async {
    sandbox = await Sandbox.setUp();
  });

  tearDown(() async {
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
    final settingButton = find.descendant(
      of: find.bySubtype<AppBar>(),
      matching: find.byIcon(Icons.more_vert_rounded),
    );
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
}

Future<void> init(WidgetTester tester) async {
  final app = await initApp();

  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
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
