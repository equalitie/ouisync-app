import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/pages/main_page.dart';

void main() {
  testWidgets('onboarding', (tester) async {
    await tester.pumpWidget(await initOuiSyncApp([]));
    await tester.pumpAndSettle();

    // Go to the second onboarding page
    await tester.tap(find.text('NEXT'));
    await tester
        .pumpAndSettle(); // TODO: Do we need to call this after every interaction?

    // Go to the third onboarding page
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Go to the accept terms & conditions page
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'Ouisync is built in line with our values',
        findRichText: true,
      ),
      findsOne,
    );

    // Agree with the T&C and go to the main page
    await tester.tap(find.text('I AGREE'));
    await tester.pumpAndSettle();

    // Assert we are on the main page
    expect(find.byType(MainPage), findsOne);
  });
}
