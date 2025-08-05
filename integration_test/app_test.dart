import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ouisync_app/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sanity check', (tester) async {
    final app = await initApp();

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.text('English').first);
    await tester.pumpAndSettle();
  });
}
