import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/platform/platform.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

void main() {
  late Session session;
  late Settings settings;

  setUp(() async {
    final configPath = join(
      (await getApplicationSupportDirectory()).path,
      'config',
    );

    session = Session.create(
      kind: SessionKind.unique,
      configPath: configPath,
    );

    settings = await Settings.init(MasterKey.random());
  });

  tearDown(() async {
    await session.close();
  });

  testWidgets('onboarding', (tester) async {
    await tester.pumpWidget(testApp(OuiSyncApp(
      packageInfo: PackageInfo(
        appName: 'ouisync.test',
        packageName: 'org.equalitie.ouisync.test',
        version: '1.0.0',
        buildNumber: '42',
        buildSignature: '',
      ),
      session: session,
      settings: settings,
      windowManager: _FakeWindowManager(),
    )));
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

class _FakeWindowManager extends PlatformWindowManager {
  @override
  void onClose(CloseHandler handler) {}

  @override
  Future<void> setTitle(String title) => Future.value();

  @override
  Future<void> initSystemTray() => Future.value();
}
